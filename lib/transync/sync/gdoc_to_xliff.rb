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
      translations: {}
    }

    xliff_for_language = xliff_translations.detect{ |x| x[:language] == language }[:translations]
    gdoc_tab_language[:translations].keys.each do |trans_key|
      trans_value = gdoc_tab_language[:translations][trans_key]
      x_trans_value = xliff_for_language[trans_key]

      # whole key is missing
      if x_trans_value.nil?
        SyncUtil.info_diff(file, language, 'Adding', trans_key, nil)

        new_xliff_hash[:translations][trans_key] = trans_value
        dirty = true
      elsif trans_value != x_trans_value
        SyncUtil.info_diff(file, language, 'Changing', x_trans_value, trans_value)
        new_xliff_hash[:translations][trans_key] = trans_value
        dirty = true
      else
        # nothing new
        new_xliff_hash[:translations][trans_key] = trans_value
      end
    end

    # also merge keys that were missing in gdoc
    new_xliff_hash[:translations] = xliff_for_language.merge(new_xliff_hash[:translations])

    return dirty, new_xliff_hash
  end

end
