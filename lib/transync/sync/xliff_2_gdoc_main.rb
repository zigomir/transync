require_relative '../gdoc_trans/gdoc_trans_reader'
require_relative '../gdoc_trans/gdoc_trans_writer'
require_relative 'xliff_to_gdoc'
require_relative 'sync_util'

class Xliff2GdocMain
  attr_reader :path, :config

  def initialize(path)
    @path = path
    @config = GdocTrans::CONFIG
    SyncUtil.create_logger('xliff2gdoc')
  end

  def run
    @config['FILES'].each do |file|
      valid, xliff_translations = SyncUtil::check_and_get_xliff_files(@config['LANGUAGES'], path, file)
      abort('Fix your Xliff translations first!') unless valid

      gdoc_trans_reader = GdocTransReader.new(@config['GDOC'], file)
      gdoc_trans_writer = GdocTransWriter.new(gdoc_trans_reader.worksheet)

      @config['LANGUAGES'].each do |language|
        options = {
          xliff_translations: xliff_translations,
          gdoc_trans_reader: gdoc_trans_reader,
          gdoc_trans_writer: gdoc_trans_writer,
          language: language,
          languages: @config['LANGUAGES']
        }
        xliff_to_gdoc = XliffToGdoc.new(options)
        dirty = xliff_to_gdoc.sync

        # save it back on google drive
        gdoc_trans_writer.worksheet.save if dirty
        SyncUtil.info_clean(file, language, 'was clean. Already has same keys and values inside GDoc') unless dirty
      end
    end
  end

end
