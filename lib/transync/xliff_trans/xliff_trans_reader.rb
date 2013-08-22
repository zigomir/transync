require 'nokogiri'

class XliffTransReader
  attr_accessor :path,
                :file,
                :language,
                :languages,
                :all_translations_for_language

  def initialize(path, file, language, languages)
    self.path       = path
    self.file       = file
    self.language   = language
    self.languages  = languages
    self.all_translations_for_language = {file: file, language: nil, translations: {}}
  end

  def get_translations
    data = {
      file: file,
      language: language,
      translations: {}
    }

    open_file do |doc|
      doc.remove_namespaces!
      doc.xpath('//trans-unit').each do |node|
        key   = node.xpath('source').text
        value = node.xpath('target').text
        data[:translations][key] = value
      end
    end

    data
  end

  # will go through each and find if any xliff is missing keys for translations
  def valid?
    missing = 0
    missing_translation_text = GdocTrans::CONFIG['MISSING_TRANSLATION_TEXT'] || '#MISSING-TRANS#'

    self.get_translations[:translations].keys.each do |x_trans_key|
      self.languages.each do |key_lang|
        next if key_lang == language

        xliff_reader = XliffTransReader.new(self.path, self.file, key_lang, self.languages)
        xliff_lang = xliff_reader.get_translations[:translations]
        xliff_lang_value = xliff_lang[x_trans_key]

        all_translations_for_language[:language] = key_lang

        if xliff_lang_value.nil?
          p "#{file}.#{key_lang} is missing translation for key '#{x_trans_key}'"
          all_translations_for_language[:translations][x_trans_key] = "#{missing_translation_text} - #{x_trans_key}"
          missing += 1
        else
          all_translations_for_language[:translations][x_trans_key] = xliff_lang_value
        end
      end
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
    "#{path}/#{file}.#{language}.xliff"
  end

end
