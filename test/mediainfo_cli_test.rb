require "test_helper"
require "mediainfo_test_helper"

class MediainfoCliTest < ActiveSupport::TestCase

  #
  # Unit tests for the following "greatseth/mediainfo" patch:
  #
  # http://github.com/pvdb/mediainfo/commit/f49689a8366e629f4679bdd21e3071b0d452c34f
  #
  # ... with some help from:
  #
  # http://muffinresearch.co.uk/archives/2007/01/30/bash-single-quotes-inside-of-single-quoted-strings/
  # http://notetoself.vrensk.com/2008/08/escaping-single-quotes-in-ruby-harder-than-expected/
  #
  # ... and documented here:
  #
  # problem:   http://gist.github.com/113611
  # exception: http://gist.github.com/113614
  # quoting:   http://gist.github.com/113629
  #
    
  test "incorrect CLI works for filenames without parentheses, single quotes, spaces and double quotes" do
    info = mediainfo_incorrect_cli_mock "dinner.3g2"
    assert info.audio?
    assert info.video?
    assert_equal "MPEG-4", info.format
  end

  test "incorrect CLI does NOT work for filenames with parentheses" do
    info = mediainfo_incorrect_cli_mock "dinner(early).3g2"
    assert !info.audio?
    assert !info.video?
    assert_nil info.format
  end

  test "correct CLI works for filenames with parentheses" do
    info = mediainfo_correct_cli_mock "dinner(early).3g2"
    assert info.audio?
    assert info.video?
    assert_equal "MPEG-4", info.format
  end
  
  test "incorrect CLI does NOT work for filenames with single quotes" do
    info = mediainfo_incorrect_cli_mock "dinner's_ready.3g2"
    assert !info.audio?
    assert !info.video?
    assert_nil info.format
  end

  test "correct CLI works for filenames with single quotes" do
    info = mediainfo_correct_cli_mock "dinner's_ready.3g2"
    assert info.audio?
    assert info.video?
    assert_equal "MPEG-4", info.format
  end
  
  test "incorrect CLI does NOT work for filenames with spaces" do
    info = mediainfo_incorrect_cli_mock "fabulous dinner.3g2"
    assert !info.audio?
    assert !info.video?
    assert_nil info.format
  end

  test "correct CLI works for filenames with spaces" do
    info = mediainfo_correct_cli_mock "fabulous dinner.3g2"
    assert info.audio?
    assert info.video?
    assert_equal "MPEG-4", info.format
  end

  test "incorrect CLI does NOT work for filenames with double quotes" do
    info = mediainfo_incorrect_cli_mock "absolutely \"fabulous\" dinner.3g2"
    assert !info.audio?
    assert !info.video?
    assert_nil info.format
  end

  test "correct CLI works for filenames with double quotes" do
    info = mediainfo_correct_cli_mock "absolutely \"fabulous\" dinner.3g2"
    assert info.audio?
    assert info.video?
    assert_equal "MPEG-4", info.format
  end
  
end
