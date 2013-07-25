require 'nokogiri'

class XliffTransReader
  attr_accessor :dir, :file, :language, :languages

  def initialize(dir, file, language, languages)
    self.dir = dir
    self.file = file
    self.language = language
    self.languages = languages
  end

  def get_translations
    data = {
      language: language,
      translations: []
    }

    open_file do |doc|
      # hacky hack, xliff is dirty as hell
      doc.remove_namespaces!
      doc.xpath('//trans-unit').each do |node|
        data[:translations] << {
          key: node.xpath('source').text,
          value: node.xpath('target').text,
        }
      end
    end

    data
  end

  # will go through each and find if any xliff is missing keys for translations
  def valid?(create = false)
    missing = 0

    all_translations_for_language = {language: nil, translations: []}

    self.get_translations[:translations].each do |x_trans|
      self.languages.each do |key_lang|
        next if key_lang == language

        xliff_reader = XliffTransReader.new(self.dir, self.file, key_lang, self.languages)
        xliff_lang = xliff_reader.get_translations[:translations]
        xliff_lang_value = xliff_lang.detect{ |xt| xt[:key] == x_trans[:key] }

        all_translations_for_language[:language] = key_lang

        if xliff_lang_value.nil?
          p "#{file}.#{key_lang} is missing translation for key '#{x_trans[:key]}'" unless create
          return false unless create

          p "#{missing + 1}. #{file}.#{key_lang} was missing translation for key '#{x_trans[:key]}'."
          all_translations_for_language[:translations] << { key: x_trans[:key],  value: 'Missing translation' }
          missing += 1
        else
          all_translations_for_language[:translations] << xliff_lang_value
        end
      end
    end

    if missing > 0 and create
      xliff_trans_writer = XliffTransWriter.new(dir, file, all_translations_for_language)
      xliff_trans_writer.save
    end

    missing == 0
  end

  # Reading from source tags in xliff
  def open_file
    begin
      xml_file = File.open(file_path)
      doc = Nokogiri::XML(xml_file)
      yield doc
    rescue Errno::ENOENT => e
      abort(e.message)
    end
  end

private

  def file_path
    "#{dir}/#{file}.#{language}.xliff"
  end

end
