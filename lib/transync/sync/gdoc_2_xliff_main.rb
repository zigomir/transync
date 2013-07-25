require 'yaml'
require 'logger'
require_relative '../gdoc_trans/gdoc_trans_reader'
require_relative '../xliff_trans/xliff_trans_writer'
require_relative 'gdoc_to_xliff'
require_relative 'sync_util'

class Gdoc2XliffMain
  include SyncUtil
  attr_reader :path, :config

  def initialize(path)
    @path = path
    @config = GdocTrans::CONFIG
  end

  def run
    logger = Logger.new('.transync_log/gdoc2xliff.log', 'monthly')

    @config['FILES'].each do |file|
      xliff_translations = check_and_get_xliff_files(@config['LANGUAGES'], path, file)
      gdoc_trans_reader = GdocTransReader.new(@config['GDOC'], file)

      @config['LANGUAGES'].each do |language|
        options = {
          xliff_translations: xliff_translations,
          gdoc_trans_reader: gdoc_trans_reader,
          language: language,
          logger: logger
        }

        gdoc_to_xliff = GdocToXliff.new(options)
        dirty, new_xliff_hash = gdoc_to_xliff.sync

        xliff_trans_writer = XliffTransWriter.new(path, file, new_xliff_hash)
        xliff_trans_writer.save if dirty
        p "#{file} (#{language}) was clean. Already has same keys and values inside Xliff" unless dirty
      end
    end
  end

end
