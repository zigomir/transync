require_relative 'transync/sync/xliff_2_gdoc_main'
require_relative 'transync/sync/gdoc_2_xliff_main'
require_relative 'transync/sync/init'
require_relative 'transync/sync/sync_util'

module Transync

  def self.run(mode, path)
    FileUtils.mkdir('.transync_log') unless Dir.exist?('.transync_log')

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

    if mode == 'check'
      GdocTrans::CONFIG['FILES'].each do |file|
        SyncUtil::check_and_get_xliff_files(GdocTrans::CONFIG['LANGUAGES'], path, file)
      end
    end

    if mode == 'check_and_add_missing'
      GdocTrans::CONFIG['FILES'].each do |file|
        SyncUtil::check_and_get_xliff_files(GdocTrans::CONFIG['LANGUAGES'], path, file, true)
      end
    end
  end

end
