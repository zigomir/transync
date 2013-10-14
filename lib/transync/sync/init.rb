class Init

  def initialize(path)
    @path   = path
    @config = TransyncConfig::CONFIG
  end

  def run
    @config['FILES'].each do |file|
      worksheet = TransyncConfig::WORKSHEETS.detect{ |s| s.title == file }
      if worksheet.nil?
        worksheet = TransyncConfig::SPREADSHEET.add_worksheet(file)
        p "Adding #{file} worksheet to spreadsheet with first row (key and languages)"
      end

      worksheet[1, 1] = 'Key'
      @config['LANGUAGES'].each_with_index do |language, index|
        worksheet[1, index + 2] = language.upcase
      end
      worksheet.save
    end

    # re-init spreadsheet after new worksheets were created
    TransyncConfig.init_spreadsheet
    sync = TranslationSync.new(@path, 'x2g')
    sync.run('x2g', nil)
  end

end
