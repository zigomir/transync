require_relative '../gdoc_trans/gdoc_trans_reader'
require_relative '../xliff_trans/xliff_trans_reader'

class XliffToGdoc

  def initialize(options = {})
    @path   = options[:path]
    @file   = options[:file]
    @config = GdocTrans::CONFIG
  end

  def build_new_hash(language)
    gdoc_trans_reader  = GdocTransReader.new(@config['GDOC'], @file)
    xliff_trans_reader = XliffTransReader.new(@path, @file, language, nil) # we dont need languages for get_translations method

    # TODO - freaking inconsistent API as hell
    # both readers should have same method name for getting translations, and both should be limited to a language
    g_trans_hash = gdoc_trans_reader.build_trans_hash(language)
    x_trans_hash = xliff_trans_reader.get_translations

    g_trans_hash.merge(x_trans_hash)
  end

end
