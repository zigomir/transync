require_relative '../xliff_trans/xliff_trans_writer'
require_relative 'gdoc_to_xliff'
require_relative 'sync_util'

class Gdoc2XliffMain

  def initialize(path)
    @path   = path
    @config = TransyncConfig::CONFIG
    SyncUtil.create_logger('gdoc2xliff')
  end

  def run
    @config['FILES'].each do |file|
      valid, _ = SyncUtil::check_and_get_xliff_files(@config['LANGUAGES'], @path, file)
      abort('Fix your Xliff translations first!') unless valid

      xliff_trans_writer = XliffTransWriter.new(@path, file)

      @config['LANGUAGES'].each do |language|
        options = {
          path: @path,
          file: file
        }
        gdoc_to_xliff = GdocToXliff.new(options)
        trans_hash = gdoc_to_xliff.build_new_hash(language)
        xliff_trans_writer.write(language, trans_hash)
      end
    end
  end

end
