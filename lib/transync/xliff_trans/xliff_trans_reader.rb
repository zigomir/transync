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
  def valid?
    self.get_translations[:translations].each do |x_trans|
      self.languages.each do |key_lang|
        next if key_lang == language

        xliff_reader = XliffTransReader.new(self.dir, self.file, key_lang, self.languages)
        xliff_lang = xliff_reader.get_translations[:translations]
        xliff_lang_value = xliff_lang.detect{ |xt| xt[:key] == x_trans[:key] }
        if xliff_lang_value.nil?
          p "#{file}.#{key_lang} is missing translation for key '#{x_trans[:key]}'"
          return false
        end
      end
    end

    true
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
