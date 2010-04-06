require "test_helper"
require "mediainfo_test_helper"

class MediainfoMultipleStreamsTest < ActiveSupport::TestCase
  def setup
    @info = mediainfo_mock "multiple-streams"
  end

  ### GENERAL
  
  test_stream_type_queries :expect => [:audio, :video, :menu]
  
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
    assert_equal 85000, @info.duration
    assert_equal "1mn 25s", @info.duration_before_type_cast
  end

  test "overall bitrate" do
    assert_equal "9 872 Kbps", @info.overall_bit_rate
  end
  
  test "mastered date" do
    assert_nil @info.mastered_date
  end
  
  test "encoded date" do
    assert_equal Time.parse("UTC 2009-08-18 16:42:50"), @info.encoded_date
  end
  
  test "tagged date" do
    assert_equal Time.parse("UTC 2009-08-18 16:42:55"), @info.tagged_date
  end

  test "writing application" do
    assert_equal "Sorenson Squeeze 5.0", @info.writing_application
  end
  
  test "writing library" do
    assert_equal "Apple QuickTime", @info.writing_library
  end

  ### VIDEO
  
  test "video streams count" do
    assert_equal 2, @info.video.count
  end
  
  # stream 1
  
  test "video 1 stream id" do
    assert_equal "2", @info.video[0].stream_id
  end
  
  test "video 1   Format" do
    assert_equal "AVC", @info.video[0].format
  end
  
  test "video 1   Format info" do
    assert_equal "Advanced Video Codec", @info.video[0].format_info
  end
  
  test "video 1 format profile" do
    assert_equal "Baseline@L3.2", @info.video[0].format_profile
  end
  
  test "video 1 format version" do
    assert_nil @info.video[0].format_version
  end
  
  test "video 1 format settings Matrix" do
    assert_nil @info.video[0].format_settings_matrix
  end
  
  test "video 1 format settings CABAC" do
    assert_equal "No", @info.video[0].format_settings_cabac
  end
  
  test "video 1 format settings ReFrames" do
    assert_equal "4 frames", @info.video[0].format_settings_reframes
  end

  test "video 1   Codec ID" do
    assert_equal "avc1", @info.video[0].codec_id
  end
  
  test "video 1   Codec ID info" do
    assert_equal "Advanced Video Coding", @info.video[0].codec_id_info
  end

  test "video 1   Duration" do
    assert_equal 85000, @info.video[0].duration
    assert_equal "1mn 25s", @info.video[0].duration_before_type_cast
  end

  test "video 1   Bit rate" do
    assert_equal "9 392 Kbps", @info.video[0].bit_rate
  end
  
  test "video 1 nominal bit rate" do
    assert_nil @info.video[0].nominal_bit_rate
  end
  
  test "video 1 bit rate mode" do
    assert_equal "Variable", @info.video[0].bit_rate_mode
    assert @info.video[0].vbr?
    assert !@info.video[0].cbr?
  end
  
  test "video 1 resolution" do
    assert_equal 24, @info.video[0].resolution
  end

  test "video 1   Width" do
    assert_equal 1280, @info.video[0].width
  end

  test "video 1   Height" do
    assert_equal 720, @info.video[0].height
  end
  
  test "video 1 frame size" do
    assert_equal "1280x720", @info.video[0].frame_size
  end

  test "video 1   Display aspect ratio" do
    assert_equal "16:9", @info.video[0].display_aspect_ratio
  end

  test "video 1 frame rate" do
    assert_equal "29.970 fps", @info.video[0].frame_rate
    assert_equal 29.97, @info.video[0].fps
    assert_equal 29.97, @info.video[0].framerate
    
    assert_equal 29.94, @info.video[0].min_fps
    assert_equal 29.97, @info.video[0].max_fps
  end
  
  test "video 1 frame rate mode" do
    assert_equal "Variable", @info.video[0].frame_rate_mode
  end

  test "video 1   Resolution" do
    assert_equal 24, @info.video[0].resolution
    assert_equal "24 bits", @info.video[0].resolution_before_type_cast
  end
  
  test "video 1 standard" do
    assert_equal "NTSC", @info.video[0].standard
  end
  
  test "video 1 colorimetry" do
    assert_equal "4:2:0", @info.video[0].colorimetry
    assert_equal "4:2:0", @info.video[0].colorspace
  end

  test "video 1   Scan type" do
    assert_equal "Progressive", @info.video[0].scan_type
    assert !@info.video[0].interlaced?
    assert @info.video[0].progressive?
  end
  
  test "video 1 scan order" do
    assert_nil @info.video[0].scan_order
  end

  test "video 1   Bits/(Pixel*Frame)" do
    assert_equal "0.340", @info.video[0].bits_pixel_frame
  end

  test "video 1   Stream size" do
    assert_equal "95.6 MiB (95%)", @info.video[0].stream_size
  end
  
  # stream 2
  
  test "video 2 stream id" do
    assert_equal "6", @info.video[1].stream_id
  end
  
  test "video 2   Format" do
    assert_equal "AVC", @info.video[1].format
  end
  
  test "video 2 format profile" do
    assert_equal "Baseline@L3.2", @info.video[1].format_profile
  end
  
  test "video 2 format version" do
    assert_nil @info.video[1].format_version
  end
  
  test "video 2 format settings Matrix" do
    assert_nil @info.video[1].format_settings_matrix
  end
  
  test "video 2 format settings CABAC" do
    assert_equal "No", @info.video[1].format_settings_cabac
  end
  
  test "video 2 format settings ReFrames" do
    assert_equal "4 frames", @info.video[1].format_settings_reframes
  end

  test "video 2   Codec ID" do
    assert_equal "avc1", @info.video[1].codec_id
  end
  
  test "video 2   Codec ID info" do
    assert_equal "Advanced Video Coding", @info.video[1].codec_id_info
  end

  test "video 2   Duration" do
    assert_equal 4170, @info.video[1].duration
    assert_equal "4s 170ms", @info.video[1].duration_before_type_cast
  end

  test "video 2   Bit rate" do
    assert_equal "656 Kbps", @info.video[1].bit_rate
  end
  
  test "video 2 nominal bit rate" do
    assert_nil @info.video[1].nominal_bit_rate
  end
  
  test "video 2 bit rate mode" do
    assert_equal "Variable", @info.video[1].bit_rate_mode
    assert @info.video[1].vbr?
    assert !@info.video[1].cbr?
  end
  
  test "video 2 frame size" do
    assert_equal "1280x720", @info.video[1].frame_size
  end

  test "video 2   Width" do
    assert_equal 1280, @info.video[1].width
  end

  test "video 2   Height" do
    assert_equal 720, @info.video[1].height
  end

  test "video 2   Display aspect ratio" do
    assert_equal "16:9", @info.video[1].display_aspect_ratio
  end

  test "video 2 frame rate" do
    assert_equal "29.970 fps", @info.video[1].frame_rate
    assert_equal 29.97, @info.video[1].fps
    assert_equal 29.97, @info.video[1].framerate
  end
  
  test "video 2 frame rate mode" do
    assert_equal "Constant", @info.video[1].frame_rate_mode
  end

  test "video 2   Resolution" do
    assert_equal 24, @info.video[1].resolution
    assert_equal "24 bits", @info.video[1].resolution_before_type_cast
  end
  
  test "video 2 colorimetry" do
    assert_equal "4:2:0", @info.video[1].colorimetry
    assert_equal "4:2:0", @info.video[1].colorspace
  end

  test "video 2   Scan type" do
    assert_equal "Progressive", @info.video[1].scan_type
    assert !@info.video[1].interlaced?
    assert @info.video[1].progressive?
  end
  
  test "video 2 scan order" do
    assert_nil @info.video[1].scan_order
  end

  test "video 2   Bits/(Pixel*Frame)" do
    assert_equal "0.024", @info.video[1].bits_pixel_frame
  end

  test "video 2   Stream size" do
    assert_equal "334 KiB (0%)", @info.video[1].stream_size
  end

  ### AUDIO
  
  test "audio streams count" do
    assert_equal 2, @info.audio.count
  end
  
  # stream 1
  
  test "audio 1 stream id" do
    assert_equal "1", @info.audio[0].stream_id
  end
  
  test "audio 1   Format" do
    assert_equal "AAC", @info.audio[0].format
  end
  
  test "audio 1 format info" do
    assert_equal "Advanced Audio Codec", @info.audio[0].format_info
  end
  
  test "audio 1 format version" do
    assert_equal "Version 4", @info.audio[0].format_version
  end
  
  test "audio 1 format profile" do
    assert_equal "LC", @info.audio[0].format_profile
  end
  
  test "audio 1 format settings SBR" do
    assert_equal "No", @info.audio[0].format_settings_sbr
  end
  
  test "audio 1 codec id" do
    assert_equal "40", @info.audio[0].codec_id
  end
  
  test "audio 1 codec id hint" do
    assert_nil @info.audio[0].codec_id_hint
  end
  
  test "audio 1 Format settings, Endianness" do
    assert_nil @info.audio[0].format_settings_endianness
  end
  
  test "audio 1 Format settings, Sign" do
    assert_nil @info.audio[0].format_settings_sign
  end

  test "audio 1   Codec ID" do
    assert_equal "40", @info.audio[0].codec_id
  end

  test "audio 1   Codec ID/Info" do
    assert_nil @info.audio[0].codec_info
  end

  test "audio 1   Duration" do
    assert_equal 85000, @info.audio[0].duration
    assert_equal "1mn 25s", @info.audio[0].duration_before_type_cast
  end

  test "audio 1   Bit rate mode" do
    assert_equal "Variable", @info.audio[0].bit_rate_mode
  end

  test "audio 1   Bit rate" do
    assert_equal "256 Kbps", @info.audio[0].bit_rate
  end

  test "audio 1   Channel(s)" do
    assert_equal 2, @info.audio[0].channels
  end
  
  test "audio 1 channel positions" do
    assert_equal "L R", @info.audio[0].channel_positions
  end
  
  test "audio 1 stereo?" do
    assert @info.audio[0].stereo?
  end
  
  test "audio 1 mono?" do
    assert !@info.audio[0].mono?
  end

  test "audio 1   Sampling rate" do
    assert_equal 48000, @info.audio[0].sample_rate
    assert_equal 48000, @info.audio[0].sampling_rate
    assert_equal "48.0 KHz", @info.audio[0].sampling_rate_before_type_cast
  end

  test "audio 1 resolution" do
    assert_equal 16, @info.audio[0].resolution
    assert_equal "16 bits", @info.audio[0].resolution_before_type_cast
  end

  test "audio 1   Stream size" do
    assert_equal "2.61 MiB (3%)", @info.audio[0].stream_size
  end

  test "audio 1   Interleave, duration" do
    assert_nil @info.audio[0].interleave_duration
  end
  
  test "audio 1 tagged date" do
    assert_kind_of Time, @info.audio[0].tagged_date
  end
  
  test "audio 1 encoded date" do
    assert_kind_of Time, @info.audio[0].encoded_date
  end
  
  # stream 2
  
  test "audio 2 stream id" do
    assert_equal "5", @info.audio[1].stream_id
  end
  
  test "audio 2   Format" do
    assert_equal "AAC", @info.audio[1].format
  end
  
  test "audio 2   Format version" do
    assert_equal "Version 4", @info.audio[1].format_version
  end
  
  test "audio 2   Format profile" do
    assert_equal "LC", @info.audio[1].format_profile
  end
  
  test "audio 2 format info" do
    assert_equal "Advanced Audio Codec", @info.audio[1].format_info
  end
  
  test "audio 2 codec id hint" do
    assert_nil @info.audio[1].codec_id_hint
  end
  
  test "audio 2 Format settings, Endianness" do
    assert_nil @info.audio[1].format_settings_endianness
  end
  
  test "audio 1 format settings SBR" do
    assert_equal "No", @info.audio[1].format_settings_sbr
  end
  
  test "audio 2 Format settings, Sign" do
    assert_nil @info.audio[1].format_settings_sign
  end

  test "audio 2   Codec ID" do
    assert_equal "40", @info.audio[1].codec_id
  end

  test "audio 2   Codec ID/Info" do
    assert_nil @info.audio[1].codec_info
  end

  test "audio 2   Duration" do
    assert_equal 4156, @info.audio[1].duration
    assert_equal "4s 156ms", @info.audio[1].duration_before_type_cast
  end

  test "audio 2   Bit rate mode" do
    assert_equal "Constant", @info.audio[1].bit_rate_mode
  end

  test "audio 2   Bit rate" do
    assert_equal "256 Kbps", @info.audio[1].bit_rate
  end

  test "audio 2   Channel(s)" do
    assert_equal 2, @info.audio[1].channels
  end
  
  test "audio 2 channel positions" do
    assert_equal "L R", @info.audio[1].channel_positions
  end
  
  test "audio 2 stereo?" do
    assert @info.audio[1].stereo?
  end
  
  test "audio 2 mono?" do
    assert !@info.audio[1].mono?
  end

  test "audio 2   Sampling rate" do
    assert_equal 44100, @info.audio[1].sample_rate
    assert_equal 44100, @info.audio[1].sampling_rate
    assert_equal "44.1 KHz", @info.audio[1].sampling_rate_before_type_cast
  end

  test "audio 2 resolution" do
    assert_equal 16, @info.audio[1].resolution
    assert_equal "16 bits", @info.audio[1].resolution_before_type_cast
  end

  test "audio 2   Stream size" do
    assert_equal "130 KiB (0%)", @info.audio[1].stream_size
  end

  test "audio 2   Interleave, duration" do
    assert_nil @info.audio[1].interleave_duration
  end
  
  test "audio 1 tagged date" do
    assert_kind_of Time, @info.audio[1].tagged_date
  end
  
  test "audio 1 encoded date" do
    assert_kind_of Time, @info.audio[1].encoded_date
  end
  
  ### IMAGE
  
  mediainfo_test_not_an_image
  
  ### MENU
  
  test "menu" do
    assert @info.menu?
    assert @info.menu.stream_id
    assert @info.menu.encoded_date
    assert @info.menu.tagged_date
    assert @info.menu.delay
  end
end
