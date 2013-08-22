require 'yaml'

module GdocTrans
  WORKSHEET_COLUMNS = { key: 1 }
  START_ROW = 2

  begin
    CONFIG = YAML.load(File.open('transync.yml'))
  rescue
    p 'File transync.yml does not exist'
    exit(1)
  end

  # populate languages dynamically from settings yaml file
  CONFIG['LANGUAGES'].each_with_index do |language, index|
    key = language
    value = index + 2
    WORKSHEET_COLUMNS[key.to_sym] = value
  end

  # Result of WORKSHEET_COLUMNS should be something like this
  # depends on LANGUAGES set in settings yaml file
  # WORKSHEET_COLUMNS = { key: 1, en: 2, de: 3 }
end
