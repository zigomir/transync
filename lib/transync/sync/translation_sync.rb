require_relative '../gdoc_trans/gdoc_trans_reader'
require_relative '../gdoc_trans/gdoc_trans_writer'
require_relative '../xliff_trans/xliff_trans_writer'

class TranslationSync

  def initialize(path, direction, file = nil)
    @path   = path
    @file   = file
    @config = TransyncConfig::CONFIG
    SyncUtil.create_logger(direction)
  end

  def run(direction)
    @config['FILES'].each do |file|
      valid, _ = SyncUtil::check_and_get_xliff_files(@config['LANGUAGES'], @path, file)
      abort('Fix your Xliff translations first!') unless valid

      @config['LANGUAGES'].each do |language|
        trans_sync = TranslationSync.new(@path, direction, file)
        trans_hash = trans_sync.sync(language, direction)

        if direction == 'x2g'
          gdoc_trans_reader = GdocTransReader.new(file)
          gdoc_trans_writer = GdocTransWriter.new(gdoc_trans_reader.worksheet)
          gdoc_trans_writer.write(language, trans_hash)
        else
          xliff_trans_writer = XliffTransWriter.new(@path, file)
          xliff_trans_writer.write(language, trans_hash)
        end
      end
    end
  end

  def sync(language, direction)
    gdoc_trans_reader  = GdocTransReader.new(@file)
    xliff_trans_reader = XliffTransReader.new(@path, @file, nil) # we dont need languages for translations method

    g_trans_hash = gdoc_trans_reader.translations(language)
    x_trans_hash = xliff_trans_reader.translations(language)

    # We need to merge on translations hash, not whole hash since it will only merge first level
    x2g_merged_translations = g_trans_hash[:translations].merge(x_trans_hash[:translations])
    g2x_merged_translations = x_trans_hash[:translations].merge(g_trans_hash[:translations])

    merged_translations = direction == 'x2g' ? x2g_merged_translations : g2x_merged_translations
    {file: @file, language: language, translations: merged_translations}
  end

end
