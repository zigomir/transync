require 'yaml'
require 'google_drive'

module TransyncConfig
  # Result of WORKSHEET_COLUMNS should be something like this
  # depends on LANGUAGES set in settings yaml file
  # WORKSHEET_COLUMNS = { key: 1, en: 2, de: 3 }
  WORKSHEET_COLUMNS = { key: 1 }
  START_ROW = 2

  def self.init_spreadsheet
    session     = GoogleDrive.login(CONFIG['GDOC']['email'], CONFIG['GDOC']['password'])
    spreadsheet = session.spreadsheet_by_key(CONFIG['GDOC']['key'])
    worksheets  = spreadsheet.worksheets

    return spreadsheet, worksheets
  end

  begin
    CONFIG = YAML.load(File.open('transync.yml'))
    SPREADSHEET, WORKSHEETS = TransyncConfig.init_spreadsheet
  rescue => e
    p e.message
    exit(1)
  end

  # populate languages dynamically from settings yaml file
  CONFIG['LANGUAGES'].each_with_index do |language, index|
    key = language
    value = index + 2
    WORKSHEET_COLUMNS[key.to_sym] = value
  end
end
