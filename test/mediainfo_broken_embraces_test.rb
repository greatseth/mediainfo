require "test_helper"
require "mediainfo_test_helper"

class MediainfoBrokenEmbracesTest < ActiveSupport::TestCase
  def setup
    @info = mediainfo_mock "Broken Embraces_510_780_576x432.mp4"
  end

  ### GENERAL
  
  test "audio?" do
    assert @info.audio?
  end
  
  test "video?" do
    assert @info.video?
  end
  
  test "format" do
    assert_equal "MPEG-4", @info.format
  end

  test "format profile" do
    assert_equal "Base Media", @info.format_profile
  end

  test "codec id" do
    assert_equal "isom", @info.codec_id
  end

  mediainfo_test_size

  test "duration" do
    assert_equal 106000, @info.duration
    assert_equal "1mn 46s", @info.duration_before_type_cast
  end

  test "overall bitrate" do
    assert_equal "911 Kbps", @info.overall_bit_rate
  end

  test "encoded date" do
    assert_nil @info.encoded_date
  end

  test "tagged date" do
    assert_nil @info.tagged_date
  end

  test "writing application" do
    assert_equal "Lavf52.39.0", @info.writing_application
  end

  test "writing library" do
    assert_nil @info.writing_library
  end

  ### VIDEO
  
  test "video stream id" do
    assert_equal "1", @info.video_stream_id
  end

  test "video   Format" do
    assert_equal "AVC", @info.video_format
  end
  
  test "video format version" do
    assert_nil @info.video_format_version
  end
  
  test "video format settings Matrix" do
    assert_nil @info.video_format_settings_matrix
  end
  
  test "video format profile" do
    assert_equal "High@L3.0", @info.video_format_profile
  end
  
  test "video format settings CABAC" do
    assert_equal "Yes", @info.video_format_settings_cabac
  end
  
  test "video format settings ReFrames" do
    assert_equal "4 frames", @info.video_format_settings_reframes
  end

  test "video   Codec ID" do
    assert_equal "avc1", @info.video_codec_id
  end
  
  test "video codec info" do
    assert_equal "Advanced Video Coding", @info.video_codec_info
  end

  test "video   Duration" do
    assert_equal 106000, @info.video_duration
    assert_equal "1mn 46s", @info.video_duration_before_type_cast
  end
  
  test "video bit rate mode" do
    assert_equal "Variable", @info.video_bit_rate_mode
    assert @info.vbr?
    assert !@info.cbr?
  end

  test "video   Bit rate" do
    assert_equal "780 Kbps", @info.video_bit_rate
  end
  
  test "video nominal bit rate" do
    assert_nil @info.video_nominal_bit_rate
  end
  
  test "resolution" do
    assert_equal "576x432", @info.resolution
  end
  
  test "video   Width" do
    assert_equal 576, @info.video_width
    assert_equal 576, @info.width
  end

  test "video   Height" do
    assert_equal 432, @info.video_height
    assert_equal 432, @info.height
  end

  test "video   Display aspect ratio" do
    assert_equal "4:3", @info.video_display_aspect_ratio
    assert_equal "4:3", @info.display_aspect_ratio
  end

  test "video   Frame rate" do
    assert_equal "23.976 fps", @info.video_frame_rate
    assert_equal 23.976, @info.fps
    assert_equal 23.976, @info.framerate
  end
  
  test "video frame rate mode" do
    assert_equal "Variable", @info.video_frame_rate_mode
  end

  test "video   Resolution" do
    assert_equal 24, @info.video_resolution
  end
  
  test "video colorimetry" do
    assert_equal "4:2:0", @info.video_colorimetry
    assert_equal "4:2:0", @info.video_colorspace
  end

  test "video   Scan type" do
    assert_equal "Progressive", @info.video_scan_type
    assert !@info.interlaced?
    assert @info.progressive?
  end
  
  test "video scan order" do
    assert_nil @info.video_scan_order
  end

  test "video   Bits/(Pixel*Frame)" do
    assert_equal "0.131", @info.video_bits_pixel_frame
  end

  test "video   Stream size" do
    assert_equal "9.84 MiB (85%)", @info.video_stream_size
  end
  
  test "video encoded date" do
    assert_nil @info.video_encoded_date
  end
  
  test "video tagged date" do
    assert_nil @info.video_tagged_date
  end

  ### AUDIO
  
  test "audio stream id" do
    assert_equal "2", @info.audio_stream_id
  end
  
  test "audio   Format" do 
    assert_equal "AAC", @info.audio_format
  end
  
  test "audio format info" do
    assert_equal "Advanced Audio Codec", @info.audio_format_info
  end
  
  test "audio Format settings, Endianness" do
    assert_nil @info.audio_format_settings_endianness
  end
  
  test "audio Format settings, Sign" do
    assert_nil @info.audio_format_settings_sign
  end
  
  test "audio   Codec ID" do
    assert_equal "40", @info.audio_codec_id
  end

  test "audio   Codec ID/Info" do
    assert_nil @info.audio_codec_info
  end

  test "audio   Duration" do
    assert_equal 106000, @info.audio_duration
    assert_equal "1mn 46s", @info.audio_duration_before_type_cast
  end

  test "audio   Bit rate mode" do
    assert_equal "Variable", @info.audio_bit_rate_mode
  end

  test "audio   Bit rate" do
    assert_equal "128 Kbps", @info.audio_bit_rate
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
    assert_equal 44100, @info.audio_sample_rate
    assert_equal 44100, @info.audio_sampling_rate
    assert_equal "44.1 KHz", @info.audio_sampling_rate_before_type_cast
  end

  test "audio   Resolution" do
    assert_equal 16, @info.audio_resolution
  end

  test "audio   Stream size" do
    assert_equal "1.62 MiB (14%)", @info.audio_stream_size
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
  
  mediainfo_test_not_an_image
end
