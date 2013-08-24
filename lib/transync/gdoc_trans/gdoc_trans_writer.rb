require 'google_drive'

class GdocTransWriter

  def initialize(worksheet)
    @worksheet = worksheet
  end

  def write(trans_hash)
    language    = trans_hash[:language]
    lang_column = get_language_column_index(language)
    abort("Language (#{language}) not found in worksheet (#{@worksheet.title})!") if lang_column == 0

    row = 2

    trans_hash[:translations].keys.each do |trans_key|
      trans_value = trans_hash[:translations][trans_key]
      @worksheet[row, 1]           = trans_key
      @worksheet[row, lang_column] = trans_value
      row += 1
    end

    @worksheet.save
  end

  def get_language_column_index(language)
    (2..@worksheet.num_cols).each do |column|
      return column if @worksheet[1, column].downcase == language.downcase
    end
    0
  end

end
