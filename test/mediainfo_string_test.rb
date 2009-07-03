require "test_helper"
require "mediainfo_test_helper"

class MediainfoStringTest < ActiveSupport::TestCase
  test "escaping slashes" do
    assert_equal '$\'foo\\\bar\'', 'foo\bar'.shell_escape
  end
  
  test "escaping quotes" do
    assert_equal '$\'foo\\\'bar\'', "foo'bar".shell_escape
  end
end
