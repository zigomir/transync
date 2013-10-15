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
    added = false
    clean = true

    check_all do |lang_a, lang_b, xliff_lang_value, x_trans_key, translations_lang_b, last| # x_trans_key comes from lang_a translations
      all_translations_for_language[:language] = lang_b

      if xliff_lang_value.nil?
        p "Comparing #{file}.#{lang_a} against #{file}.#{lang_b} => #{file}.#{lang_b} "\
          "was missing translation for key '#{x_trans_key}' => setting value: '#{missing_translation_text} - #{x_trans_key}'"
        all_translations_for_language[:translations][x_trans_key] = "#{missing_translation_text} - #{x_trans_key}"
        added = true
        clean = false
      else
        all_translations_for_language[:translations][x_trans_key] = xliff_lang_value
      end

      if last
        if added
          all_translations_for_language[:translations] = translations_lang_b.merge(all_translations_for_language[:translations])
          xliff_trans_writer = XliffTransWriter.new(path, file)
          xliff_trans_writer.write(all_translations_for_language)
        end

        # clear
        all_translations_for_language[:translations] = {}
        added = false
      end
    end

    # return if any key was added
    clean
  end

  def check_all
    self.languages.each do |lang_a|
      self.languages.each do |lang_b|
        next if lang_a == lang_b

        xliff_reader = XliffTransReader.new(self.path, self.file, self.languages)
        translations_lang_a = self.translations(lang_a)[:translations]
        keys = translations_lang_a.keys
        i = 1

        keys.each do |x_trans_key|
          translations_lang_b = xliff_reader.translations(lang_b)[:translations]
          xliff_lang_value = translations_lang_b[x_trans_key]

          yield(lang_a, lang_b, xliff_lang_value, x_trans_key, translations_lang_b, keys.length == i) # last key?
          i += 1
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
