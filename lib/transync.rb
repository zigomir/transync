require_relative 'transync/sync/xliff_2_gdoc_main'
require_relative 'transync/sync/gdoc_2_xliff_main'

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
  end

end
