require "test_helper"
require "mediainfo_test_helper"

class MediainfoVimeoTest < ActiveSupport::TestCase
  def setup
    @info = mediainfo_mock "vimeo.57652.avi"
  end

  ### GENERAL
  
  test "audio?" do
    assert @info.audio?
  end
  
  test "video?" do
    assert @info.video?
  end
  
  test "format" do
    assert_equal "AVI", @info.format
  end
  
  test "format profile" do
    assert_nil @info.format_profile
  end
  
  test "codec id" do
    assert_nil @info.codec_id
  end

  mediainfo_test_size

  test "duration" do
    assert_equal 15164, @info.duration
    assert_equal "15s 164ms", @info.duration_before_type_cast
  end

  test "overall bitrate" do
    assert_equal "2 078 Kbps", @info.overall_bit_rate
  end
  
  test "mastered date" do
    assert_nil @info.encoded_date
  end
  
  test "encoded date" do
    assert_nil @info.encoded_date
  end
  
  test "tagged date" do
    assert_nil @info.tagged_date
  end

  test "writing application" do
    assert_equal "CASIO EX-Z55", @info.writing_application
  end
  
  test "writing library" do
    assert_nil @info.writing_library
  end

  ### VIDEO
  
  test "video stream  id" do
    assert_equal "0", @info.video.stream_id
  end
  
  test "video   Format" do
    assert_equal "M-JPEG", @info.video.format
  end
  
  test "video format profile" do
    assert_nil @info.video.format_profile
  end
  
  test "video format version" do
    assert_nil @info.video.format_version
  end
  
  test "video format settings Matrix" do
    assert_nil @info.video.format_settings_matrix
  end
  
  test "video format settings CABAC" do
    assert_nil @info.video.format_settings_cabac
  end
  
  test "video format settings ReFrames" do
    assert_nil @info.video.format_settings_reframes
  end

  test "video   Codec ID" do
    assert_equal "MJPG", @info.video.codec_id
  end

  test "video   Duration" do
    assert_equal 15164, @info.video.duration
    assert_equal "15s 164ms", @info.video.duration_before_type_cast
  end

  test "video   Bit rate" do
    assert_equal "2 019 Kbps", @info.video.bit_rate
  end
  
  test "video nominal bit rate" do
    assert_nil @info.video.nominal_bit_rate
  end
  
  test "video bit rate mode" do
    assert_nil @info.video.bit_rate_mode
    assert @info.video.vbr?
    assert !@info.video.cbr?
  end
  
  test "frame size" do
    assert_equal "320x240", @info.video.frame_size
  end

  test "video   Width" do
    assert_equal 320, @info.video.width
  end

  test "video   Height" do
    assert_equal 240, @info.video.height
  end

  test "video   Display aspect ratio" do
    assert_equal "4:3", @info.video.display_aspect_ratio
  end

  test "video frame rate" do
    assert_equal "15.102 fps", @info.video.frame_rate
    assert_equal 15.102, @info.video.fps
    assert_equal 15.102, @info.video.framerate
  end
  
  test "video frame rate mode" do
    assert_nil @info.video.frame_rate_mode
  end

  test "video   Resolution" do
    assert_equal 24, @info.video.resolution
    assert_equal "24 bits", @info.video.resolution_before_type_cast
  end
  
  test "video colorimetry" do
    assert_nil @info.video.colorimetry
    assert_nil @info.video.colorspace
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
    assert_equal "1.741", @info.video.bits_pixel_frame
  end

  test "video   Stream size" do
    assert_equal "3.65 MiB (97%)", @info.video.stream_size
  end

  ### AUDIO
  
  test "audio stream id" do
    assert_nil @info.audio.stream_id
  end
  
  test "audio   Format" do
    assert_equal "ADPCM", @info.audio.format
  end
  
  test "audio format info" do
    assert_nil @info.audio.format_info
  end
  
  test "audio codec id hint" do
    assert_equal "Intel", @info.audio.codec_id_hint
  end
  
  test "audio Format settings, Endianness" do
    assert_nil @info.audio.format_settings_endianness
  end
  
  test "audio Format settings, Sign" do
    assert_nil @info.audio.format_settings_sign
  end

  test "audio   Codec ID" do
    assert_equal "11", @info.audio.codec_id
  end

  test "audio   Codec ID/Info" do
    assert_nil @info.audio.codec_info
  end

  test "audio   Duration" do
    assert_equal 15164, @info.audio.duration
    assert_equal "15s 164ms", @info.audio.duration_before_type_cast
  end

  test "audio   Bit rate mode" do
    assert_equal "Constant", @info.audio.bit_rate_mode
  end

  test "audio   Bit rate" do
    assert_equal "44.1 Kbps", @info.audio.bit_rate
  end

  test "audio   Channel(s)" do
    assert_equal 1, @info.audio.channels
  end
  
  test "audio channel positions" do
    assert_nil @info.audio.channel_positions
  end
  
  test "stereo?" do
    assert !@info.audio.stereo?
  end
  
  test "mono?" do
    assert @info.audio.mono?
  end

  test "audio   Sampling rate" do
    assert_equal 11025, @info.audio.sample_rate
    assert_equal 11025, @info.audio.sampling_rate
    assert_equal "11.025 KHz", @info.audio.sampling_rate_before_type_cast
  end

  test "audio resolution" do
    assert_equal 4, @info.audio.resolution
    assert_equal "4 bits", @info.audio.resolution_before_type_cast
  end

  test "audio   Stream size" do
    assert_equal "82.8 KiB (2%)", @info.audio.stream_size
  end

  test "audio   Interleave, duration" do
    assert_equal "67 ms (1.00 video frame)", @info.audio.interleave_duration
  end
  
  test "audio encoded date" do
    assert_nil @info.audio.encoded_date
  end
  
  test "audio tagged date" do
    assert_nil @info.audio.tagged_date
  end
  
  ### IMAGE
  
  mediainfo_test_not_an_image
end
