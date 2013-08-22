require_relative 'sync_util'

class XliffToGdoc
  attr_accessor :xliff_translations,
                :gdoc_trans_reader,
                :gdoc_trans_writer,
                :language,
                :languages,
                :logger

  def initialize(options = {})
    self.xliff_translations = options[:xliff_translations]
    self.gdoc_trans_reader = options[:gdoc_trans_reader]
    self.gdoc_trans_writer = options[:gdoc_trans_writer]
    self.language = options[:language]
    self.languages = options[:languages]
  end

  def sync
    gdoc_tab_language = gdoc_trans_reader.build_trans_hash(language)
    dirty = false
    file = gdoc_tab_language[:file]

    xliff_for_language = xliff_translations.detect{ |x| x[:language] == language }
    xliff_for_language[:translations].each_with_index do |x_trans, index|

      # for current xliff translation find the same trans key in google doc
      gdoc_trans = gdoc_tab_language[:translations].detect{ |g_trans| g_trans[:key] == x_trans[:key] }
      current_row = index + GdocTrans::START_ROW

      # whole key is missing
      if gdoc_trans.nil?
        # heavy coupling
        gdoc_trans_reader.worksheet = gdoc_trans_writer.shift_up(current_row, xliff_for_language[:translations].length)
        # recalculate hashes after shift
        gdoc_tab_language = gdoc_trans_reader.build_trans_hash(language)

        gdoc_trans_writer.write(current_row, 'key',    x_trans[:key])
        gdoc_trans_writer.write(current_row, language, x_trans[:value])

        SyncUtil.info_diff(file, language, 'Adding', x_trans)

        # Go for all other languages if key was missing
        languages.each do |key_lang|
          next if key_lang == language

          xliff_lang = xliff_translations.detect{ |xt| xt[:language] == key_lang }
          xliff_lang_value = xliff_lang[:translations].detect{ |xt| xt[:key] == x_trans[:key] }

          gdoc_trans_writer.write(current_row, key_lang, xliff_lang_value[:value])
        end

        dirty = true
      elsif gdoc_trans[:value] != x_trans[:value]
        gdoc_trans_writer.write(current_row, language, x_trans[:value])
        SyncUtil.info_diff(file, language, 'Changing', x_trans)
        dirty = true
      end
    end

    dirty
  end

end
