require "test_helper"
require "mediainfo_test_helper"

class MediainfoAwaywegoTest < ActiveSupport::TestCase
  def setup
    @info = mediainfo_mock "AwayWeGo_24fps.mov"
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
    assert_equal "QuickTime", @info.format_profile
  end

  test "codec id" do
    assert_equal "qt", @info.codec_id
  end

  mediainfo_test_size

  test "duration" do
    assert_equal 36286, @info.duration
    assert_equal "36s 286ms", @info.duration_before_type_cast
  end

  test "overall bitrate" do
    assert_equal "42.7 Mbps", @info.overall_bit_rate
  end

  test "encoded date" do
    assert_kind_of Time, @info.encoded_date
    # assert_equal "UTC 2009-03-30 19:49:13", @info.encoded_date
  end

  test "tagged date" do
    assert_kind_of Time, @info.tagged_date
    # assert_equal "UTC 2009-03-30 19:57:57", @info.tagged_date
  end

  test "writing application" do
    assert_nil @info.writing_application
  end

  test "writing library" do
    assert_equal "Apple QuickTime", @info.writing_library
  end

  ### VIDEO
  
  test "video stream id" do
    assert_equal "2", @info.video.stream_id
  end
  
  test "video   Format" do
    assert_equal "AVC", @info.video.format
  end
  
  test "video format profile" do
    assert_equal "Main@L4.1", @info.video.format_profile
  end
  
  test "video format version" do
    assert_nil @info.video.format_version
  end
  
  test "video format settings Matrix" do
    assert_nil @info.video.format_settings_matrix
  end
  
  test "video format settings CABAC" do
    assert_equal "No", @info.video.format_settings_cabac
  end
  
  test "video format settings ReFrames" do
    assert_equal "2 frames", @info.video.format_settings_reframes
  end

  test "video   Codec ID" do
    assert_equal "avc1", @info.video.codec_id
  end
  
  test "video codec info" do
    assert_equal "Advanced Video Coding", @info.video.codec_info
  end

  test "video   Duration" do
    assert_equal 36286, @info.video.duration
    assert_equal "36s 286ms", @info.video.duration_before_type_cast
  end
  
  test "video bit rate mode" do
    assert_equal "Variable", @info.video.bit_rate_mode
    assert @info.video.vbr?
    assert !@info.video.cbr?
  end

  test "video   Bit rate" do
    assert_equal "41.2 Mbps", @info.video.bit_rate
  end
  
  test "video nominal bit rate" do
    assert_nil @info.video.nominal_bit_rate
  end
  
  test "frame size" do
    assert_equal "1920x840", @info.video.frame_size
  end
  
  test "video   Width" do
    assert_equal 1920, @info.video.width
  end

  test "video   Height" do
    assert_equal 840, @info.video.height
  end

  test "video   Display aspect ratio" do
    assert_equal "2.25:1", @info.video.display_aspect_ratio
  end

  test "video frame rate" do
    assert_equal "23.976 fps", @info.video.frame_rate
    assert_equal 23.976, @info.video.fps
    assert_equal 23.976, @info.video.framerate
  end
  
  test "video frame rate mode" do
    assert_equal "Constant", @info.video.frame_rate_mode
  end

  test "video   Resolution" do
    assert_equal 24, @info.video.resolution
    assert_equal "24 bits", @info.video.resolution_before_type_cast
  end
  
  test "video colorimetry" do
    assert_equal "4:2:0", @info.video.colorimetry
    assert_equal "4:2:0", @info.video.colorspace
  end

  test "video   Scan type" do
    assert_equal "Progressive", @info.video.scan_type
    assert !@info.video.interlaced?
    assert @info.video.progressive?
  end
  
  test "video scan order" do
    assert_nil @info.video.scan_order
  end

  test "video   Bits/(Pixel*Frame)" do
    assert_equal "1.065", @info.video.bits_pixel_frame
  end

  test "video   Stream size" do
    assert_equal "178 MiB (96%)", @info.video.stream_size
  end
  
  test "video encoded date" do
    assert_kind_of Time, @info.video.encoded_date
  end
  
  test "video tagged date" do
    assert_kind_of Time, @info.video.tagged_date
  end
  
  test "video color primaries" do
    assert_equal \
      "BT.709-5, BT.1361, IEC 61966-2-4, SMPTE RP177",
      @info.video.color_primaries
  end
  
  test "video transfer characteristics" do
    assert_equal "BT.709-5, BT.1361", @info.video.transfer_characteristics
  end
  
  test "video matrix coefficients" do
    assert_equal \
      "BT.709-5, BT.1361, IEC 61966-2-4 709, SMPTE RP177",
      @info.video.matrix_coefficients
  end

  ### AUDIO
  
  test "audio stream id" do
    assert_equal "1", @info.audio.stream_id
  end
  
  test "audio   Format" do 
    assert_equal "PCM", @info.audio.format
  end
  
  test "audio format info" do
    assert_nil @info.audio.format_info
  end
  
  test "audio Format settings, Endianness" do
    assert_equal "Little", @info.audio.format_settings_endianness
  end
  
  test "audio Format settings, Sign" do
    assert_equal "Signed", @info.audio.format_settings_sign
  end
  
  test "audio   Codec ID" do
    assert_equal "sowt", @info.audio.codec_id
  end

  test "audio   Codec ID/Info" do
    assert_nil @info.audio.codec_info
  end

  test "audio   Duration" do
    assert_equal 36286, @info.audio.duration
    assert_equal "36s 286ms", @info.audio.duration_before_type_cast
  end

  test "audio   Bit rate mode" do
    assert_equal "Constant", @info.audio.bit_rate_mode
  end

  test "audio   Bit rate" do
    assert_equal "1 536 Kbps", @info.audio.bit_rate
  end

  test "audio   Channel(s)" do
    assert_equal 2, @info.audio.channels
  end
  
  test "audio channel positions" do
    assert_nil @info.audio.channel_positions
  end
  
  test "stereo?" do
    assert @info.audio.stereo?
  end
  
  test "mono?" do
    assert !@info.audio.mono?
  end

  test "audio   Sampling rate" do
    assert_equal 48000, @info.audio.sample_rate
    assert_equal 48000, @info.audio.sampling_rate
    assert_equal "48.0 KHz", @info.audio.sampling_rate_before_type_cast
  end

  test "audio resolution" do
    assert_equal 16, @info.audio.resolution
    assert_equal "16 bits", @info.audio.resolution_before_type_cast
  end

  test "audio   Stream size" do
    assert_equal "6.64 MiB (4%)", @info.audio.stream_size
  end

  test "audio   Interleave, duration" do
    assert_nil @info.audio.interleave_duration
  end
  
  test "audio encoded date" do
    assert_kind_of Time, @info.audio.encoded_date
  end
  
  test "audio tagged date" do
    assert_kind_of Time, @info.audio.tagged_date
  end
  
  ### IMAGE
  
  mediainfo_test_not_an_image
end
