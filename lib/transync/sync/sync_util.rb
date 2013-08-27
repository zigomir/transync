require 'logger'
require_relative '../xliff_trans/xliff_trans_reader'

module SyncUtil

  def self.check_and_get_xliff_files(languages, path, file)
    valid = true
    xliff_translations = []
    all_translations_for_language = {}

    languages.each do |language|
      xliff_reader = XliffTransReader.new(path, file, languages)
      if xliff_reader.valid?
        xliff_translations << xliff_reader.translations(language)
      else
        valid = false
        all_translations_for_language = xliff_reader.all_translations_for_language
      end
    end

    return valid, xliff_translations, all_translations_for_language
  end

  def self.info_clean(file, language, message)
    msg = "#{file} (#{language}) - #{message}"
    SyncUtil.log_and_puts(msg)
  end

  def self.info_diff(file, language, diff)
    msg = "#{file} (#{language})"
    if diff.empty?
      msg += ' already has same keys and values'
    else
      msg = build_diff_print(diff, msg)
    end
    SyncUtil.log_and_puts(msg)
  end

  def self.build_diff_print(diff, msg)
    begin
      # get longest key and value
      max_key_length = diff.keys.max { |a, b| a.length <=> b.length }.length
      max_val_length = diff.values.max { |a, b| a[1].to_s.length <=> b[1].to_s.length }[1].length
    rescue
      max_key_length = 0
      max_val_length = 0
    end

    diff.keys.each do |key|
      operation = diff[key][1].nil? ? 'Adding' : 'Changing'
      msg += "\n  #{operation.ljust(8)} - #{key.ljust(max_key_length)}: '#{diff[key][1].to_s.ljust(max_val_length)}' => '#{diff[key][0]}' "
    end
    msg
  end

  def self.log_and_puts(msg)
    puts msg
    @logger.info msg
  end

  def self.create_logger(direction)
    @logger = Logger.new(".transync_log/#{direction}.log", 'monthly')
  end

end
