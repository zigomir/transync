# TODO GdocToXliff and XliffToGdoc are the same now -> merge them

class GdocToXliff

  def initialize(options = {})
    @path = options[:path]
    @file = options[:file]
  end

  def build_new_hash(language)
    gdoc_trans_reader  = GdocTransReader.new(@file)
    xliff_trans_reader = XliffTransReader.new(@path, @file, nil) # we dont need languages for translations method

    g_trans_hash = gdoc_trans_reader.translations(language)
    x_trans_hash = xliff_trans_reader.translations(language)

    # We need to merge on translations hash, not whole hash since it will only merge first level
    merged_translations = x_trans_hash[:translations].merge(g_trans_hash[:translations])
    {file: @file, language: language, translations: merged_translations}
  end

end
