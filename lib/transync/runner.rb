require 'colorize'

module Transync

  # 2713 = unicode check mark
  # 2717 = unicode cross mark
  module Runner

    PATH = TransyncConfig::CONFIG['XLIFF_FILES_PATH']

    def self.sync(mode)
      sync = TranslationSync.new(PATH, mode)
      sync.run(mode)
    end

    def self.init
      init = Init.new(PATH)
      init.run
    end

    def self.test
      TransyncConfig::CONFIG['FILES'].each do |file|
        xliff_files = XliffTransReader.new(PATH, file, TransyncConfig::CONFIG['LANGUAGES'])
        puts "\u{2713} '#{file}' have all the keys for all languages in XLIFF files.".colorize(:green) if xliff_files.valid?

        TransyncConfig::CONFIG['LANGUAGES'].each do |language|
          trans_sync = TranslationSync.new(PATH, 'test', file)

          if trans_sync.diff(language).keys.length == 0
            puts "\u{2713} '#{file}' is in sync for '#{language}' language with GDoc.".colorize(:green)
          else
            puts "\u{2717} '#{file}' is NOT in sync for '#{language}' language with GDoc. See diff!".colorize(:red)
          end
        end

        puts '----------'
      end
    end

    def self.update
      TransyncConfig::CONFIG['FILES'].each do |file|
        xliff_files = XliffTransReader.new(PATH, file, TransyncConfig::CONFIG['LANGUAGES'])
        clean = xliff_files.fill_with_missing_keys

        if clean
          puts "\u{2713} '#{file}' already have all the keys in all the XLIFF files".colorize(:green)
        else
          puts "\u{2717} '#{file}' already DID NOT have all the keys in all the XLIFF files. But they were added automatically for you.".colorize(:red)
        end
      end
    end

  end
end
