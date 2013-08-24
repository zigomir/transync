require_relative '../transync_config'

class GdocTransReader
  attr_reader :worksheet

  # file represents tab in spreadsheet
  def initialize(file)
    @worksheet = TransyncConfig::WORKSHEETS.detect{ |w| w.title == file }
    abort("#{file} tab is not defined in GDoc") if @worksheet.nil?
  end

  def translations(language)
    trans_hash = { file: @worksheet.title, language: language, translations: {} }
    key_column      = TransyncConfig::WORKSHEET_COLUMNS[:key]
    language_column = TransyncConfig::WORKSHEET_COLUMNS[language.to_sym]

    (TransyncConfig::START_ROW..@worksheet.num_rows).to_a.each do |row|
      key   = @worksheet[row, key_column]
      value = @worksheet[row, language_column]
      trans_hash[:translations][key] = value
    end

    trans_hash
  end

end
