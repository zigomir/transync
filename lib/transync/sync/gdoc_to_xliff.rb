require_relative 'sync_util'

class GdocToXliff
  attr_accessor :xliff_translations,
                :gdoc_trans_reader,
                :language

  def initialize(options = {})
    self.xliff_translations = options[:xliff_translations]
    self.gdoc_trans_reader = options[:gdoc_trans_reader]
    self.language = options[:language]
  end

  def sync
    dirty = false
    gdoc_tab_language = gdoc_trans_reader.build_trans_hash(language)
    file = gdoc_tab_language[:file]

    new_xliff_hash = {
      file: file,
      language: language,
      translations: []
    }

    xliff_for_language = xliff_translations.detect{ |x| x[:language] == language }[:translations]
    gdoc_tab_language[:translations].each do |gdoc_trans|
      x_trans = xliff_for_language.detect{ |x| x[:key] == gdoc_trans[:key] }

      # whole key is missing
      if x_trans.nil?
        SyncUtil.info_diff(file, language, 'Adding', gdoc_trans)

        new_xliff_hash[:translations] << gdoc_trans
        dirty = true
      elsif gdoc_trans[:value] != x_trans[:value]
        SyncUtil.info_diff(file, language, 'Changing', gdoc_trans)

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
