require 'minitest/spec'
require 'minitest/autorun'

require_relative '../lib/transync/gdoc_trans/gdoc_trans'
require_relative '../lib/transync/gdoc_trans/gdoc_trans_reader'
require_relative '../lib/transync/sync/sync_util'
require_relative '../lib/transync/sync/gdoc_to_xliff'

describe GdocTransReader do
  before do
    @file = 'test' # file or worksheet title aka spreadsheet tab
    @path = 'test/fixtures'
    @config = GdocTrans::CONFIG
    @gdoc_trans_reader = GdocTransReader.new(@config['GDOC'], @file)
    @language = 'en'
    SyncUtil.create_logger('gdoc2xliff_test')
  end

  it 'should build correct trans hash' do
    trans_hash = @gdoc_trans_reader.build_trans_hash(@language)
    trans_hash[:file].must_equal @file
    trans_hash[:language].must_equal @language
    trans_hash[:translations].size.must_equal 3
    trans_hash[:translations][0][:key].must_equal 'title'
    trans_hash[:translations][0][:value].must_equal 'Title'
    trans_hash[:translations][1][:key].must_equal 'round'
    trans_hash[:translations][1][:value].must_equal 'Round'
    trans_hash[:translations][2][:key].must_equal 'end_test'
    trans_hash[:translations][2][:value].must_equal 'meh'

    p trans_hash
  end

  it 'should build correct new xliff hash' do
    # TODO test this xliff_translations
    xliff_translations = SyncUtil::check_and_get_xliff_files(%w(en), @path, @file)
    p xliff_translations

    options = {
      xliff_translations: xliff_translations,
      gdoc_trans_reader: @gdoc_trans_reader,
      language: @language
    }

    gdoc_to_xliff = GdocToXliff.new(options)
    dirty, new_xliff_hash = gdoc_to_xliff.sync
    p new_xliff_hash

    dirty.must_equal true

    new_xliff_hash[:file].must_equal @file
    new_xliff_hash[:language].must_equal @language
    #new_xliff_hash[:translations].size.must_equal 3
  end
end
