require "test_helper"
require "mediainfo_test_helper"

class MediainfoAwaywegoEncodedTest < ActiveSupport::TestCase
  def setup
    @info = mediainfo_mock "AwayWeGo_24fps_253_15000_1920x840.mov"
  end

  ### GENERAL
  
  test "audio?" do
    assert @info.audio?
  end
  
  test "video?" do
    assert @info.video?
  end
  
  test "format" do
    assert_equal "MPEG-PS", @info.format
  end

  test "format profile" do
    assert_nil @info.format_profile
  end

  test "codec id" do
    assert_nil @info.codec_id
  end

  mediainfo_test_size

  test "duration" do
    assert_equal 36224, @info.duration
    assert_equal "36s 224ms", @info.duration_before_type_cast
  end

  test "overall bitrate" do
    assert_equal "17.3 Mbps", @info.overall_bit_rate
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
  
  test "video stream id" do
    assert_equal "224 (0xE0)", @info.video_stream_id
  end

  test "video   Format" do
    assert_equal "MPEG Video", @info.video_format
  end
  
  test "video format version" do
    assert_equal "Version 2", @info.video_format_version
  end
  
  test "video format settings Matrix" do
    assert_equal "Default", @info.video_format_settings_matrix
  end
  
  test "video format profile" do
    assert_nil @info.video_format_profile
  end
  
  test "video format settings CABAC" do
    assert_nil @info.video_format_settings_cabac
  end
  
  test "video format settings ReFrames" do
    assert_nil @info.video_format_settings_reframes
  end

  test "video   Codec ID" do
    assert_nil @info.video_codec_id
  end
  
  test "video codec info" do
    assert_nil @info.video_codec_info
  end

  test "video   Duration" do
    assert_equal 36202, @info.video_duration
    assert_equal "36s 202ms", @info.video_duration_before_type_cast
  end
  
  test "video bit rate mode" do
    assert_equal "Constant", @info.video_bit_rate_mode
    assert !@info.vbr?
    assert @info.cbr?
  end

  test "video   Bit rate" do
    assert_equal "16.0 Mbps", @info.video_bit_rate
  end
  
  test "video nominal bit rate" do
    assert_equal "15.0 Mbps", @info.video_nominal_bit_rate
  end
  
  test "resolution" do
    assert_equal "1920x1080", @info.resolution
  end
  
  test "video   Width" do
    assert_equal 1920, @info.video_width
    assert_equal 1920, @info.width
  end

  test "video   Height" do
    assert_equal 1080, @info.video_height
    assert_equal 1080, @info.height
  end

  test "video   Display aspect ratio" do
    assert_equal "16/9", @info.video_display_aspect_ratio
    assert_equal "16/9", @info.display_aspect_ratio
  end

  test "video   Frame rate" do
    assert_equal "29.970 fps", @info.video_frame_rate
    assert_equal "29.970", @info.fps
    assert_equal "29.970", @info.framerate
  end
  
  test "video frame rate mode" do
    assert_nil @info.video_frame_rate_mode
  end

  test "video   Resolution" do
    assert_nil @info.video_resolution
  end
  
  test "video colorimetry" do
    assert_equal "4:2:2", @info.video_colorimetry
    assert_equal "4:2:2", @info.video_colorspace
  end

  test "video   Scan type" do
    assert_equal "Interlaced", @info.video_scan_type
    assert @info.interlaced?
    assert !@info.progressive?
  end
  
  test "video scan order" do
    assert_equal "Bottom Field First", @info.video_scan_order
  end

  test "video   Bits/(Pixel*Frame)" do
    assert_equal "0.258", @info.video_bits_pixel_frame
  end

  test "video   Stream size" do
    assert_nil @info.video_stream_size
  end
  
  test "video encoded date" do
    assert_nil @info.video_encoded_date
    # assert_equal "UTC 2009-03-30 19:57:50", @info.video_encoded_date
  end
  
  test "video tagged date" do
    assert_nil @info.video_tagged_date
    # assert_equal "UTC 2009-03-30 19:57:57", @info.video_tagged_date
  end

  ### AUDIO
  
  test "audio stream id" do
    assert_equal "128 (0x80)", @info.audio_stream_id
  end
  
  test "audio   Format" do 
    assert_equal "AC-3", @info.audio_format
  end
  
  test "audio format info" do
    assert_equal "Audio Coding 3", @info.audio_format_info
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
    assert_equal 36224, @info.audio_duration
    assert_equal "36s 224ms", @info.audio_duration_before_type_cast
  end

  test "audio   Bit rate mode" do
    assert_equal "Constant", @info.audio_bit_rate_mode
  end

  test "audio   Bit rate" do
    assert_equal "64.0 Kbps", @info.audio_bit_rate
  end

  test "audio   Channel(s)" do
    assert_equal 2, @info.audio_channels
  end
  
  test "audio channel positions" do
    assert_equal "L R", @info.audio_channel_positions
  end
  
  test "stereo?" do
    assert @info.stereo?
  end
  
  test "mono?" do
    assert !@info.mono?
  end

  test "audio   Sampling rate" do
    assert_equal "48.0 KHz", @info.audio_sampling_rate
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
    # assert_equal "UTC 2009-03-30 19:57:50", @info.audio_encoded_date
  end
  
  test "audio tagged date" do
    assert_nil @info.audio_tagged_date
    # assert_equal "UTC 2009-03-30 19:57:57", @info.audio_tagged_date
  end
  
  ### IMAGE
  
  mediainfo_test_not_an_image
end
