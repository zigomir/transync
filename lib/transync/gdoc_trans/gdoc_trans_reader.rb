require 'google_drive'
require_relative '../transync'

class GdocTransReader
  attr_accessor :worksheet

  def initialize(gdoc_access, tab)
    session = GoogleDrive.login(gdoc_access['email'], gdoc_access['password'])

    worksheet_tabs = session.spreadsheet_by_key(gdoc_access['key']).worksheets
    # select the right tab from worksheet
    self.worksheet = worksheet_tabs.detect{ |w| w.title == tab }
    abort("#{tab} tab is not defined in GDoc") if self.worksheet.nil?
  end

  def translations(language)
    trans_hash = { file: worksheet.title, language: language, translations: {} }

    key_column = Transync::WORKSHEET_COLUMNS[:key]
    language_column = Transync::WORKSHEET_COLUMNS[language.to_sym]

    (Transync::START_ROW..worksheet.num_rows).to_a.each do |row|
      key   = worksheet[row, key_column]
      value = worksheet[row, language_column]
      trans_hash[:translations][key] = value
    end

    trans_hash
  end

end
