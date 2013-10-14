require 'minitest/spec'
require 'minitest/autorun'

require_relative '../lib/transync/gdoc_trans/gdoc_trans_reader'
require_relative '../lib/transync/xliff_trans/xliff_trans_writer'
require_relative '../lib/transync/sync/sync_util'

describe 'update' do
  before do
    @path      = 'test/fixtures'
    @languages = %w(en de fr)
    SyncUtil.create_logger('update_test')
  end

  it 'test if xliff files are valid' do
    xliff_files = XliffTransReader.new(@path, 'validators', @languages)
    xliff_files.valid?.must_equal false, 'validators translations should not be valid, because we do not have all keys in german file.'

    xliff_files.fill_with_missing_keys
    xliff_files.valid?.must_equal true, 'validators translations should be valid after running fill_with_missing_keys'
  end
end
