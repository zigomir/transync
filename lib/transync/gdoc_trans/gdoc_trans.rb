module GdocTrans
  WORKSHEET_COLUMNS = { key: 1 }
  START_ROW = 2

  CONFIG = YAML.load(File.open('settings.yml'))

  # populate languages dynamically from settings.yml
  CONFIG['LANGUAGES'].each_with_index do |language, index|
    key = language
    value = index + 2 #

    WORKSHEET_COLUMNS[key.to_sym] = value
  end

  # Result of WORKSHEET_COLUMNS should be something like this
  # depends on LANGUAGES set in settings.yml
  # WORKSHEET_COLUMNS = { key: 1, en: 2, de: 3 }
end
