require_relative '../gdoc_trans/gdoc_trans_writer'

class Init
  attr_reader :path, :config

  def initialize(path)
    @path = path
    @config = TransyncConfig::CONFIG
  end

  def run
    @config['FILES'].each do |file|
      worksheet = TransyncConfig::WORKSHEETS.select { |s| s.title == file }.first
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
    sync = TranslationSync.new(@path, 'x2g')
    sync.run('x2g')
  end

end
