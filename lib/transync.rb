require_relative 'transync/sync/translation_sync'
require_relative 'transync/sync/init'
require_relative 'transync/sync/sync_util'

module Transync

  def self.run(mode, test = nil)
    FileUtils.mkdir('.transync_log') unless Dir.exist?('.transync_log')
    path = TransyncConfig::CONFIG['XLIFF_FILES_PATH']

    if mode == 'x2g' or mode == 'g2x'
      sync = TranslationSync.new(path, mode)
      sync.run(mode, test)
    end

    if mode == 'init'
      init = Init.new(path)
      init.run
    end

    if mode == 'test'
      TransyncConfig::CONFIG['FILES'].each do |file|
        xliff_files = XliffTransReader.new(path, file, TransyncConfig::CONFIG['LANGUAGES'])
        p 'All translation have all keys, great!' if xliff_files.valid?
      end
    end

    if mode == 'update'
      TransyncConfig::CONFIG['FILES'].each do |file|
        xliff_files = XliffTransReader.new(path, file, TransyncConfig::CONFIG['LANGUAGES'])
        xliff_files.fill_with_missing_keys
      end
    end
  end

end
