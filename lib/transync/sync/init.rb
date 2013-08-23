require_relative '../gdoc_trans/gdoc_trans_writer'
require_relative 'xliff_to_gdoc'

class Init
  attr_reader :path, :config

  def initialize(path)
    @path = path
    @config = TransyncConfig::CONFIG
    @gdoc_access = @config['GDOC']
  end

  def run
    # first we want to add all the files to spreadsheet as worksheets (tabs)
    # add_worksheet(title, max_rows = 100, max_cols = 20)
    session = GoogleDrive.login(@gdoc_access['email'], @gdoc_access['password'])
    spreadsheet = session.spreadsheet_by_key(@gdoc_access['key'])

    @config['FILES'].each do |file|
      worksheet = spreadsheet.worksheets.select { |s| s.title == file }.first
      if worksheet.nil?
        worksheet = spreadsheet.add_worksheet(file)
        p "Adding #{file} worksheet to spreadsheet with first row (key and languages)"
      end

      worksheet[1, 1] = 'Key'
      @config['LANGUAGES'].each_with_index do |language, index|
        worksheet[1, index + 2] = language.upcase
      end
      worksheet.save
    end

    # now sync all our keys and translations to gdoc
    # this won't work if local files are not 'clean'.
    # to make them clean run test and update first!
    x2g = Xliff2GdocMain.new(path)
    x2g.run
  end

end
