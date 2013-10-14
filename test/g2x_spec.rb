require 'minitest/spec'
require 'minitest/autorun'

require_relative '../lib/transync/transync_config'
require_relative '../lib/transync/gdoc_trans/gdoc_trans_reader'
require_relative '../lib/transync/sync/sync_util'
require_relative '../lib/transync/sync/translation_sync'

# Expects this data in test worksheet
# Key	      EN	    DE
# title	    Title	  Titel
# round	    Round	  Rund
# end_test	meh	    xxx
describe 'g2x' do
  before do
    @file     = 'test' # file or worksheet title aka spreadsheet tab
    @path     = 'test/fixtures'
    @language = 'en'
    SyncUtil.create_logger('g2x_test')
  end

  it 'google doc translation reader should build correct trans hash' do
    gdoc_trans_reader = GdocTransReader.new(@file)
    trans_hash = gdoc_trans_reader.translations(@language)
    trans_hash[:file].must_equal @file
    trans_hash[:language].must_equal @language
    trans_hash[:translations].keys.size.must_equal 3

    trans_hash[:translations]['title'].must_equal 'Title'
    trans_hash[:translations]['round'].must_equal 'Round'
    trans_hash[:translations]['end_test'].must_equal 'meh'
  end

  it 'g2x sync should build new hash before writing it to xliff' do
    trans_sync     = TranslationSync.new(@path, 'g2x', @file)
    new_xliff_hash = trans_sync.sync(@language, 'g2x')

    new_xliff_hash[:file].must_equal @file
    new_xliff_hash[:language].must_equal @language
    new_xliff_hash[:translations].size.must_equal 4

    new_xliff_hash[:translations]['end_test'].must_equal 'meh'
    new_xliff_hash[:translations]['end_test_2'].must_equal 'End test 2'
  end
end
