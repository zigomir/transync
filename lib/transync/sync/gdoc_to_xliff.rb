class GdocToXliff
  attr_accessor :xliff_translations,
                :gdoc_trans_reader,
                :language,
                :logger

  def initialize(options = {})
    self.xliff_translations = options[:xliff_translations]
    self.gdoc_trans_reader = options[:gdoc_trans_reader]
    self.language = options[:language]
    self.logger = options[:logger]
  end

  def sync
    dirty = false
    gdoc_tab_language = gdoc_trans_reader.build_trans_hash(language)
    file = gdoc_tab_language[:title]

    new_xliff_hash = {
      language: language,
      file: file,
      translations: []
    }

    xliff_for_language = xliff_translations.detect{ |x| x[:language] == language }[:translations]
    gdoc_tab_language[:translations].each do |gdoc_trans|
      x_trans = xliff_for_language.detect{ |x| x[:key] == gdoc_trans[:key] }

      # whole key is missing
      if x_trans.nil?
        p "Adding Key: #{gdoc_trans[:key]} to #{file}(#{language}) and value '#{gdoc_trans[:value]}'"
        logger.info "Adding Key: #{gdoc_trans[:key]} to #{file}(#{language}) and value '#{gdoc_trans[:value]}'"

        new_xliff_hash[:translations] << gdoc_trans
        dirty = true
      elsif gdoc_trans[:value] != x_trans[:value]
        p "Changing #{file}(#{language}) #{gdoc_trans[:key]}: '#{x_trans[:value]}' to '#{gdoc_trans[:value]}'"
        logger.info "Changing #{file}(#{language}) #{gdoc_trans[:key]}: '#{x_trans[:value]}' to '#{gdoc_trans[:value]}'"

        x_trans[:value] = gdoc_trans[:value]
        new_xliff_hash[:translations] << x_trans
        dirty = true
      else
        # nothing new
        new_xliff_hash[:translations] << gdoc_trans
      end
    end

    return dirty, new_xliff_hash
  end

end
