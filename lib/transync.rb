require_relative 'transync/sync/translation_sync'
require_relative 'transync/sync/init'
require_relative 'transync/sync/sync_util'

module Transync

  def self.run(mode)
    FileUtils.mkdir('.transync_log') unless Dir.exist?('.transync_log')
    path = TransyncConfig::CONFIG['XLIFF_FILES_PATH']

    if mode == 'x2g' or mode == 'g2x'
      sync = TranslationSync.new(path, mode)
      sync.run(mode)
    end

    if mode == 'init'
      init = Init.new(path)
      init.run
    end

    if mode == 'test'
      TransyncConfig::CONFIG['FILES'].each do |file|
        SyncUtil::check_and_get_xliff_files(TransyncConfig::CONFIG['LANGUAGES'], path, file)
      end
    end

    # TODO not finished yet
    if mode == 'update'
      TransyncConfig::CONFIG['FILES'].each do |file|
        valid, _, all_translations_for_language =
          SyncUtil::check_and_get_xliff_files(TransyncConfig::CONFIG['LANGUAGES'], path, file)

        #unless valid
        #  xliff_trans_writer = XliffTransWriter.new(path, file)
        #  xliff_trans_writer.save(language, trans_hash)
        #end
      end
      p 'All xliff files should now have all the keys!'
    end
  end

end
