require "test_helper"
require "mediainfo_test_helper"

class MediainfoOmenImageTest < ActiveSupport::TestCase
  def setup
    @info = mediainfo_mock "omen1976_464_0_480x336-6.jpg"
  end

  ### GENERAL
  
  test "image?" do
    assert @info.image?
  end
  
  test "audio?" do
    assert !@info.audio?
  end
  
  test "video?" do
    assert !@info.video?
  end

  test "format" do
    assert_equal "JPEG", @info.format
  end
  
  test "format profile" do
    assert_nil @info.format_profile
  end
  
  test "codec id" do
    assert_nil @info.codec_id
  end

  mediainfo_test_size

  test "duration" do
    assert_nil @info.duration
  end

  test "overall bitrate" do
    assert_nil @info.overall_bit_rate
  end
  
  test "encoded date" do
    assert_nil @info.encoded_date
  end
  
  test "tagged date" do
    assert_nil @info.tagged_date
  end

  test "writing application" do
    assert_nil @info.writing_application
  end
  
  test "writing library" do
    assert_nil @info.writing_library
  end

  ### VIDEO
=begin
  test "video   Format" do
    assert_nil @info.video.format
  end
  
  test "video format profile" do
    assert_nil @info.video.format_profile
  end
  
  test "video format settings CABAC" do
    assert_nil @info.video.format_settings_cabac
  end
  
  test "video format settings ReFrames" do
    assert_nil @info.video.format_settings_cabac
  end

  test "video   Codec ID" do
    assert_nil @info.video.codec_id
  end

  test "video   Duration" do
    assert_nil @info.video.duration
  end

  test "video   Bit rate" do
    assert_nil @info.video.bit_rate
  end
  
  test "video bit rate mode" do
    assert_nil @info.video.bit_rate_mode
  end
  
  test "frame size" do
    assert_equal "480x336", @info.frame_size
  end

  test "video   Width" do
    assert_nil @info.video.width
  end

  test "video   Height" do
    assert_nil @info.video.height
  end

  test "video   Display aspect ratio" do
    assert_nil @info.video.display_aspect_ratio
    assert_nil @info.display_aspect_ratio
  end

  test "video   Frame rate" do
    assert_nil @info.video.frame_rate
    assert_nil @info.fps
    assert_nil @info.framerate
  end
  
  test "video frame rate mode" do
    assert_nil @info.video.frame_rate_mode
  end

  test "video   Resolution" do
    assert_nil @info.video.resolution
  end
  
  test "video colorimetry" do
    assert_nil @info.video.colorimetry
    assert_nil @info.video.colorspace
  end

  test "video   Scan type" do
    assert_nil @info.video.scan_type
    assert !@info.interlaced?
    assert !@info.progressive?
  end

  test "video   Bits/(Pixel*Frame)" do
    assert_nil @info.video.bits_pixel_frame
  end

  test "video   Stream size" do
    assert_nil @info.video.stream_size
  end

  ### AUDIO

  test "audio   Format" do
    assert_nil @info.audio.format
  end
  
  test "audio Format settings, Endianness" do
    assert_nil @info.audio.format_settings_endianness
  end
  
  test "audio Format settings, Sign" do
    assert_nil @info.audio.format_settings_sign
  end

  test "audio   Codec ID" do
    assert_nil @info.audio.codec_id
  end

  test "audio   Codec ID/Info" do
    assert_nil @info.audio.codec_info
  end

  test "audio   Duration" do
    assert_nil @info.audio.duration
  end

  test "audio   Bit rate mode" do
    assert_nil @info.audio.bit_rate_mode
  end

  test "audio   Bit rate" do
    assert_nil @info.audio.bit_rate
  end

  test "audio   Channel(s)" do
    assert_nil @info.audio.channels
  end
  
  test "stereo?" do
    assert !@info.stereo?
  end
  
  test "mono?" do
    assert !@info.mono?
  end

  test "audio   Sampling rate" do
    assert_nil @info.audio.sampling_rate
  end

  test "audio   Resolution" do
    assert_nil @info.audio.resolution
  end

  test "audio   Stream size" do
    assert_nil @info.audio.stream_size
  end

  test "audio   Interleave, duration" do
    assert_nil @info.audio.interleave_duration
  end
  
  test "audio encoded date" do
    assert_nil @info.audio.encoded_date
  end
  
  test "audio tagged date" do
    assert_nil @info.audio.tagged_date
  end
=end
  ### IMAGE
  
  test "image format" do
    assert_equal "JPEG", @info.image.format
  end
  
  test "image width" do
    assert_equal 480, @info.image.width
  end
  
  test "image height" do
    assert_equal 336, @info.image.height
  end
  
  test "image resolution" do
    assert_equal "24 bits", @info.image.resolution
  end
end
