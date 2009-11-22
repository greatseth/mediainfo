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

  test "video   Format" do
    assert_nil @info.video_format
  end
  
  test "video format profile" do
    assert_nil @info.video_format_profile
  end
  
  test "video format settings CABAC" do
    assert_nil @info.video_format_settings_cabac
  end
  
  test "video format settings ReFrames" do
    assert_nil @info.video_format_settings_cabac
  end

  test "video   Codec ID" do
    assert_nil @info.video_codec_id
  end

  test "video   Duration" do
    assert_nil @info.video_duration
  end

  test "video   Bit rate" do
    assert_nil @info.video_bit_rate
  end
  
  test "video bit rate mode" do
    assert_nil @info.video_bit_rate_mode
  end
  
  test "resolution" do
    assert_equal "480x336", @info.resolution
  end

  test "video   Width" do
    assert_nil @info.video_width
  end

  test "video   Height" do
    assert_nil @info.video_height
  end

  test "video   Display aspect ratio" do
    assert_nil @info.video_display_aspect_ratio
    assert_nil @info.display_aspect_ratio
  end

  test "video   Frame rate" do
    assert_nil @info.video_frame_rate
    assert_nil @info.fps
    assert_nil @info.framerate
  end
  
  test "video frame rate mode" do
    assert_nil @info.video_frame_rate_mode
  end

  test "video   Resolution" do
    assert_nil @info.video_resolution
  end
  
  test "video colorimetry" do
    assert_nil @info.video_colorimetry
    assert_nil @info.video_colorspace
  end

  test "video   Scan type" do
    assert_nil @info.video_scan_type
    assert !@info.interlaced?
    assert !@info.progressive?
  end

  test "video   Bits/(Pixel*Frame)" do
    assert_nil @info.video_bits_pixel_frame
  end

  test "video   Stream size" do
    assert_nil @info.video_stream_size
  end

  ### AUDIO

  test "audio   Format" do
    assert_nil @info.audio_format
  end
  
  test "audio Format settings, Endianness" do
    assert_nil @info.audio_format_settings_endianness
  end
  
  test "audio Format settings, Sign" do
    assert_nil @info.audio_format_settings_sign
  end

  test "audio   Codec ID" do
    assert_nil @info.audio_codec_id
  end

  test "audio   Codec ID/Info" do
    assert_nil @info.audio_codec_info
  end

  test "audio   Duration" do
    assert_nil @info.audio_duration
  end

  test "audio   Bit rate mode" do
    assert_nil @info.audio_bit_rate_mode
  end

  test "audio   Bit rate" do
    assert_nil @info.audio_bit_rate
  end

  test "audio   Channel(s)" do
    assert_nil @info.audio_channels
  end
  
  test "stereo?" do
    assert !@info.stereo?
  end
  
  test "mono?" do
    assert !@info.mono?
  end

  test "audio   Sampling rate" do
    assert_nil @info.audio_sampling_rate
  end

  test "audio   Resolution" do
    assert_nil @info.audio_resolution
  end

  test "audio   Stream size" do
    assert_nil @info.audio_stream_size
  end

  test "audio   Interleave, duration" do
    assert_nil @info.audio_interleave_duration
  end
  
  test "audio encoded date" do
    assert_nil @info.audio_encoded_date
  end
  
  test "audio tagged date" do
    assert_nil @info.audio_tagged_date
  end
  
  ### IMAGE
  
  test "image format" do
    assert_equal "JPEG", @info.image_format
  end
  
  test "image width" do
    assert_equal 480, @info.image_width
    assert_equal 480, @info.width
  end
  
  test "image height" do
    assert_equal 336, @info.image_height
    assert_equal 336, @info.height
  end
  
  test "image resolution" do
    assert_equal "24 bits", @info.image_resolution
  end
end
