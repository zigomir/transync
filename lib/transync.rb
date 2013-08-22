require_relative 'transync/sync/xliff_2_gdoc_main'
require_relative 'transync/sync/gdoc_2_xliff_main'
require_relative 'transync/sync/init'
require_relative 'transync/sync/sync_util'

module Transync

  def self.run(mode)
    FileUtils.mkdir('.transync_log') unless Dir.exist?('.transync_log')
    path = GdocTrans::CONFIG['XLIFF_FILES_PATH']

    if mode == 'x2g'
      x2g = Xliff2GdocMain.new(path)
      x2g.run
    end

    if mode == 'g2x'
      g2x = Gdoc2XliffMain.new(path)
      g2x.run
    end

    if mode == 'init'
      init = Init.new(path)
      init.run
    end

    if mode == 'test'
      GdocTrans::CONFIG['FILES'].each do |file|
        SyncUtil::check_and_get_xliff_files(GdocTrans::CONFIG['LANGUAGES'], path, file)
      end
    end

    if mode == 'update'
      GdocTrans::CONFIG['FILES'].each do |file|
        valid, _, all_translations_for_language =
          SyncUtil::check_and_get_xliff_files(GdocTrans::CONFIG['LANGUAGES'], path, file)

        unless valid
          xliff_trans_writer = XliffTransWriter.new(path, file, all_translations_for_language)
          xliff_trans_writer.save
        end
      end
    end
  end

end
