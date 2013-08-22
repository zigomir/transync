require 'google_drive'
require_relative 'gdoc_trans'

class GdocTransWriter

  def initialize(worksheet, all_languages)
    @worksheet     = worksheet
    @all_languages = all_languages
  end

  def write(language, trans_hash)
    lang_column = get_language_column_index(language)
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
    (2..@all_languages + 1).each do |column|
      return column if @worksheet[1, column].downcase == language.downcase
    end
    0
  end

end
