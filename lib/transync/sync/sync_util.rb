require_relative '../xliff_trans/xliff_trans_reader'

module SyncUtil

  def check_and_get_xliff_files(languages, path, file)
    xliff_translations = []

    languages.each do |language|
      xliff_reader = XliffTransReader.new(path, file, language, languages)
      if xliff_reader.valid?
        xliff_translations << xliff_reader.get_translations
      else
        abort('Fix your Xliff translations first!')
      end
    end

    xliff_translations
  end

end