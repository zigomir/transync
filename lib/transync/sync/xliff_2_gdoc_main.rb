require_relative 'sync_util'
require_relative 'translation_sync'
require_relative '../gdoc_trans/gdoc_trans_reader'
require_relative '../gdoc_trans/gdoc_trans_writer'

class Xliff2GdocMain

  def initialize(path)
    @path   = path
    @config = TransyncConfig::CONFIG
    SyncUtil.create_logger('xliff2gdoc')
  end

  def run
    @config['FILES'].each do |file|
      valid, _ = SyncUtil::check_and_get_xliff_files(@config['LANGUAGES'], @path, file)
      abort('Fix your Xliff translations first!') unless valid

      gdoc_trans_reader = GdocTransReader.new(file)
      gdoc_trans_writer = GdocTransWriter.new(gdoc_trans_reader.worksheet)

      @config['LANGUAGES'].each do |language|
        options = {
          path: @path,
          file: file
        }
        xliff_to_gdoc = TranslationSync.new(options)
        trans_hash = xliff_to_gdoc.sync(language, 'x2g')
        gdoc_trans_writer.write(language, trans_hash)
      end
    end
  end

end
