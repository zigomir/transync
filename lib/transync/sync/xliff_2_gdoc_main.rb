require_relative '../gdoc_trans/gdoc_trans_reader'
require_relative '../gdoc_trans/gdoc_trans_writer'
require_relative 'xliff_to_gdoc'
require_relative 'sync_util'

class Xliff2GdocMain

  def initialize(path)
    @path   = path
    @config = Transync::CONFIG
    SyncUtil.create_logger('xliff2gdoc')
  end

  def run
    @config['FILES'].each do |file|
      valid, _ = SyncUtil::check_and_get_xliff_files(@config['LANGUAGES'], @path, file)
      abort('Fix your Xliff translations first!') unless valid

      gdoc_trans_reader = GdocTransReader.new(@config['GDOC'], file)
      gdoc_trans_writer = GdocTransWriter.new(gdoc_trans_reader.worksheet)

      @config['LANGUAGES'].each do |language|
        options = {
          path: @path,
          file: file
        }
        xliff_to_gdoc = XliffToGdoc.new(options)
        trans_hash = xliff_to_gdoc.build_new_hash(language)
        gdoc_trans_writer.write(language, trans_hash)
      end
    end
  end

end
