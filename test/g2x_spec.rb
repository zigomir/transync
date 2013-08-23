require 'minitest/spec'
require 'minitest/autorun'

require_relative '../lib/transync/transync'
require_relative '../lib/transync/gdoc_trans/gdoc_trans_reader'
require_relative '../lib/transync/sync/sync_util'
require_relative '../lib/transync/sync/gdoc_to_xliff'

# Expects this data in test worksheet
# Key	      EN	    DE
# title	    Title	  Titel
# round	    Round	  Rund
# end_test	meh	    xxx
describe 'g2x' do
  before do
    @file = 'test' # file or worksheet title aka spreadsheet tab
    @path = 'test/fixtures'
    @config = Transync::CONFIG
    @gdoc_trans_reader = GdocTransReader.new(@config['GDOC'], @file)
    @language = 'en'
    SyncUtil.create_logger('gdoc2xliff_test')
  end

  it 'google doc translation reader should build correct trans hash' do
    trans_hash = @gdoc_trans_reader.translations(@language)
    trans_hash[:file].must_equal @file
    trans_hash[:language].must_equal @language
    trans_hash[:translations].keys.size.must_equal 3

    trans_hash[:translations]['title'].must_equal 'Title'
    trans_hash[:translations]['round'].must_equal 'Round'
    trans_hash[:translations]['end_test'].must_equal 'meh'
  end

  it 'g2x sync should build new hash before writing it to xliff' do
    _, xliff_translations = SyncUtil::check_and_get_xliff_files(%w(en), @path, @file)
    xliff_translations[0][:file].must_equal @file
    xliff_translations[0][:language].must_equal @language
    xliff_translations[0][:translations].keys.size.must_equal 4

    options = {
      path: @path,
      file: @file
    }

    gdoc_to_xliff = GdocToXliff.new(options)
    new_xliff_hash = gdoc_to_xliff.build_new_hash(@language)

    new_xliff_hash[:file].must_equal @file
    new_xliff_hash[:language].must_equal @language
    new_xliff_hash[:translations].size.must_equal 4

    new_xliff_hash[:translations]['end_test'].must_equal 'meh'
    new_xliff_hash[:translations]['end_test_2'].must_equal 'End test 2'
  end
end
