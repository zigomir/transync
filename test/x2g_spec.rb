require 'minitest/spec'
require 'minitest/autorun'

require_relative '../lib/transync/gdoc_trans/gdoc_trans'
require_relative '../lib/transync/sync/sync_util'
require_relative '../lib/transync/xliff_trans/xliff_trans_reader'

describe 'x2g' do
  before do
    @path       = 'test/fixtures'
    @config     = GdocTrans::CONFIG
    @language   = 'en'
    SyncUtil.create_logger('xliff2gdoc_test')
  end

  it 'test if xliff files are valid' do
    xliff_trans_reader = XliffTransReader.new(@path, 'test', @language, %w(en de))
    valid = xliff_trans_reader.valid?
    valid.must_equal true

    xliff_trans_reader = XliffTransReader.new(@path, 'validators', @language, %w(en de))
    valid = xliff_trans_reader.valid?
    valid.must_equal false, 'validators translations should not be valid, because we do not have all keys in german file.'
  end

  it 'test if all keys in all language files are presented' do
    valid, _, _ = SyncUtil::check_and_get_xliff_files(GdocTrans::CONFIG['LANGUAGES'], @path, 'test')
    valid.must_equal true, 'test file should have all keys in both languages'

    valid, _, all_trans = SyncUtil::check_and_get_xliff_files(GdocTrans::CONFIG['LANGUAGES'], @path, 'validators')
    valid.must_equal false, 'validators.de file is should have one key less then validators.en xliff file'
    all_trans[:translations].size.must_equal 4
  end
end
