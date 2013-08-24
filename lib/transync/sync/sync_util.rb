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

  def self.info_diff(file, language, operation, trans_key, trans_value)
    msg = "#{file} (#{language}) - #{operation}: '#{trans_key}'"
    msg += " to '#{trans_value}'" unless trans_value.nil?
    SyncUtil.log_and_puts(msg)
  end

  def self.log_and_puts(msg)
    p msg
    @logger.info msg
  end

  def self.create_logger(direction)
    @logger = Logger.new(".transync_log/#{direction}.log", 'monthly')
  end

end
