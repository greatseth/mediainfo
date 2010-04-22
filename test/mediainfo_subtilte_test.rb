require "test_helper"
require "mediainfo_test_helper"

class MediainfoSubtitleTest < ActiveSupport::TestCase
  def setup
    @info = mediainfo_mock "subtitle"
  end

  test 'text streams count' do
    assert_equal 4, @info.text.count
  end

  test "text 1 stream id" do
    assert_equal "1", @info.text[0].stream_id
  end

  test "text 1 Format" do
    assert_equal "ASS", @info.text[0].format
  end

  test "text 1   Codec ID" do
    assert_equal "S_TEXT/ASS", @info.text[0].codec_id
  end

  test "text 1   Codec ID info" do
    #assert_equal "Advanced Sub Station Alpha", @info.text[0].codec_id_info
  end

  test "text 2 stream id" do
    assert_equal "2", @info.text[1].stream_id
  end

  test "text 1 Format" do
    assert_equal "SSA", @info.text[1].format
  end

  test "text 1   Codec ID" do
    assert_equal "S_TEXT/SSA", @info.text[1].codec_id
  end

  test "text 1   Codec ID info" do
    #assert_equal "Sub Station Alpha", @info.text[1].codec_id_info
  end
end
