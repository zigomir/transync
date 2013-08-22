require_relative '../gdoc_trans/gdoc_trans_reader'
require_relative '../xliff_trans/xliff_trans_writer'
require_relative 'gdoc_to_xliff'
require_relative 'sync_util'

class Gdoc2XliffMain
  attr_reader :path, :config

  def initialize(path)
    @path = path
    @config = GdocTrans::CONFIG
    SyncUtil.create_logger('gdoc2xliff')
  end

  def run
    @config['FILES'].each do |file|
      valid, xliff_translations = SyncUtil::check_and_get_xliff_files(@config['LANGUAGES'], path, file)
      abort('Fix your Xliff translations first!') unless valid

      gdoc_trans_reader = GdocTransReader.new(@config['GDOC'], file)

      @config['LANGUAGES'].each do |language|
        options = {
          xliff_translations: xliff_translations,
          gdoc_trans_reader: gdoc_trans_reader,
          language: language
        }

        gdoc_to_xliff = GdocToXliff.new(options)
        dirty, new_xliff_hash = gdoc_to_xliff.sync

        xliff_trans_writer = XliffTransWriter.new(path, file, new_xliff_hash)
        xliff_trans_writer.save if dirty

        SyncUtil.info_clean(file, language, 'was clean. Already has same keys and values inside Xliff') unless dirty
      end
    end
  end

end
