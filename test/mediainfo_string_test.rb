require "test_helper"
require "mediainfo_test_helper"

class MediainfoStringTest < ActiveSupport::TestCase
  test "escaping slashes" do
    assert_equal '"foo\\\bar"', 'foo\bar'.shell_escape_double_quotes
  end
  
  test "escaping quotes" do
    assert_equal '"foo\"bar"', 'foo"bar'.shell_escape_double_quotes
  end
  
  test "escaping ticks" do
    assert_equal '"foo\`bar"', 'foo`bar'.shell_escape_double_quotes
  end
  
  test "escaping dollar signs" do
    assert_equal '"foo\$bar"', 'foo$bar'.shell_escape_double_quotes
  end
end
