class TranslationSync

  def initialize(options = {})
    @path = options[:path]
    @file = options[:file]
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
