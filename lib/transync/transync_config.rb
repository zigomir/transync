require 'yaml'
require 'google/api_client'
require 'google_drive'
require 'transync/version'

module TransyncConfig
  # Result of WORKSHEET_COLUMNS should be something like this
  # depends on LANGUAGES set in settings yaml file
  # WORKSHEET_COLUMNS = { key: 1, en: 2, de: 3 }
  WORKSHEET_COLUMNS = { key: 1 }
  START_ROW = 2

  @spreadsheet = nil
  @worksheets  = nil

  def self.init_spreadsheet
    # Authorizes with OAuth and gets an access token.
    client             = Google::APIClient.new(
      application_name: 'Transync',
      application_version: Transync::VERSION
    )
    auth               = client.authorization
    auth.client_id     = CONFIG['GDOC']['client_id'] # "YOUR CLIENT ID"
    auth.client_secret = CONFIG['GDOC']['client_secret'] # "YOUR CLIENT SECRET"
    auth.scope = [
        'https://www.googleapis.com/auth/drive',
        'https://spreadsheets.google.com/feeds/'
    ]
    auth.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
    print("1. Open this page:\n%s\n\n" % auth.authorization_uri)
    print('2. Enter the authorization code shown in the page: ')
    auth.code = $stdin.gets.chomp
    auth.fetch_access_token!
    access_token = auth.access_token

    # session     = GoogleDrive.login_with_oauth(CONFIG['GDOC']['email'], CONFIG['GDOC']['password'])
    session     = GoogleDrive.login_with_oauth(access_token)
    spreadsheet = session.spreadsheet_by_key(CONFIG['GDOC']['key'])
    worksheets  = spreadsheet.worksheets

    return spreadsheet, worksheets
  end

  # This gets executed automatically when module is evaluated (required?)
  begin
    CONFIG = YAML.load(File.open('transync.yml'))
    @spreadsheet, @worksheets = TransyncConfig.init_spreadsheet

    # populate languages dynamically from settings yaml file
    CONFIG['LANGUAGES'].each_with_index do |language, index|
      key = language
      value = index + 2
      WORKSHEET_COLUMNS[key.to_sym] = value
    end
  rescue => e
    p e.message
    exit(1)
  end

  # used for init command after we create new tabs
  def self.re_init
    @spreadsheet, @worksheets = TransyncConfig.init_spreadsheet
  end

  def self.worksheets
    @worksheets
  end

  def self.spreadsheet
    @spreadsheet
  end

end
