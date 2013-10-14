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
    check_all({file: file, language: nil, translations: {}})
  end

  # TODO
  #def add_missing_keys
  #  all_translations_for_language = {file: file, language: nil, translations: {}}
  #  check_all(all_translations_for_language)
  #  all_translations_for_language
  #end

  def check_all(all_translations_for_language)
    missing = 0
    missing_translation_text = TransyncConfig::CONFIG['MISSING_TRANSLATION_TEXT'] || '#MISSING-TRANS#'

    self.languages.each do |lang_1|
      self.languages.each do |lang_2|
        next if lang_1 == lang_2

        self.translations(lang_1)[:translations].keys.each do |x_trans_key|
          xliff_reader = XliffTransReader.new(self.path, self.file, self.languages)
          xliff_lang = xliff_reader.translations(lang_2)[:translations]
          xliff_lang_value = xliff_lang[x_trans_key]

          all_translations_for_language[:language] = lang_2

          if xliff_lang_value.nil?
            p "#{file}.#{lang_2} is missing translation for key '#{x_trans_key}'"
            all_translations_for_language[:translations][x_trans_key] = "#{missing_translation_text} - #{x_trans_key}"
            missing += 1
          else
            all_translations_for_language[:translations][x_trans_key] = xliff_lang_value
          end
        end
      end
    end

    missing == 0
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
