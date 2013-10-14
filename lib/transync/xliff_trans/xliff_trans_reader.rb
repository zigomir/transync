require 'nokogiri'

class XliffTransReader
  attr_accessor :path,
                :file,
                :languages

  def initialize(path, file, languages)
    self.path       = path
    self.file       = file
    self.languages  = languages
  end

  def translations(language)
    data = { file: file, language: language, translations: {} }

    open_file(language) do |doc|
      doc.remove_namespaces!
      doc.xpath('//trans-unit').each do |node|
        key   = node.xpath('source').text
        value = node.xpath('target').text
        data[:translations][key] = value
      end
    end

    data
  end

  def valid?
    missing = 0

    check_all do |lang_a, lang_b, xliff_lang_value, x_trans_key|
      if xliff_lang_value.nil?
        p "Comparing #{file}.#{lang_a} against #{file}.#{lang_b} => #{file}.#{lang_b} "\
          "is missing translation for key '#{x_trans_key}'"
        missing += 1
      end
    end

    missing == 0
  end

  def fill_with_missing_keys
    missing_translation_text = TransyncConfig::CONFIG['MISSING_TRANSLATION_TEXT'] || '#MISSING-TRANS#'
    all_translations_for_language = {file: file, language: nil, translations: {}}

    check_all do |lang_a, lang_b, xliff_lang_value, x_trans_key|
      all_translations_for_language[:language] = lang_b

      if xliff_lang_value.nil?
        p "Comparing #{file}.#{lang_a} against #{file}.#{lang_b} => #{file}.#{lang_b} "\
          "was missing translation for key '#{x_trans_key}' => replacing with #{missing_translation_text} - #{x_trans_key}"
        all_translations_for_language[:translations][x_trans_key] = "#{missing_translation_text} - #{x_trans_key}"
      else
        all_translations_for_language[:translations][x_trans_key] = xliff_lang_value
      end
    end

    all_translations_for_language
  end

  def check_all
    self.languages.each do |lang_a|
      self.languages.each do |lang_b|
        next if lang_a == lang_b

        xliff_reader = XliffTransReader.new(self.path, self.file, self.languages)
        self.translations(lang_a)[:translations].keys.each do |x_trans_key|
          xliff_lang = xliff_reader.translations(lang_b)[:translations]
          xliff_lang_value = xliff_lang[x_trans_key]

          yield lang_a, lang_b, xliff_lang_value, x_trans_key
        end
      end
    end
  end

  # Reading from source tags in xliff
  def open_file(language)
    begin
      xml_file = File.open(file_path(language))
      doc = Nokogiri::XML(xml_file)
      yield doc
    rescue Errno::ENOENT => e
      abort(e.message)
    end
  end

private

  def file_path(language)
    "#{path}/#{file}.#{language}.xliff"
  end

end
