require "test_helper"
require "mediainfo_test_helper"

class MediainfoTest < ActiveSupport::TestCase
  supported_attributes = [
    :codec_id,
    :duration,
    :format,
    :format_profile,
    :format_info,
    :overall_bit_rate,
    :writing_application,
    :writing_library,
    
    :mastered_date,
    :tagged_date,
    :encoded_date,
    
    ### VIDEO
    
    :video_stream_id,
    :video_duration,
    :video_stream_size,
    :video_bit_rate,
    :video_nominal_bit_rate,
    :video_bit_rate_mode,
    :video_scan_order,
    :video_scan_type,
    :video_resolution,
    :video_colorimetry,
    :video_standard,
    :video_format,
    :video_format_info,
    :video_format_profile,
    :video_format_version,
    :video_format_settings_cabac,
    :video_format_settings_reframes,
    :video_format_settings_matrix,
    :video_codec_id,
    :video_codec_info,
    :video_frame_rate,
    :video_minimum_frame_rate,
    :video_maximum_frame_rate,
    :video_frame_rate_mode,
    :video_display_aspect_ratio,
    :video_bits_pixel_frame,
    :video_width,
    :video_height,
    :video_encoded_date,
    :video_tagged_date,
    :video_color_primaries,
    :video_transfer_characteristics,
    :video_matrix_coefficients,

    ### AUDIO

    :audio_stream_id,
    :audio_sampling_rate,
    :audio_duration,
    :audio_stream_size,
    :audio_bit_rate,
    :audio_bit_rate_mode,
    :audio_interleave_duration,
    :audio_resolution,
    :audio_format,
    :audio_format_info,
    :audio_format_profile,
    :audio_format_settings_endianness,
    :audio_format_settings_sign,
    :audio_format_settings_sbr,
    :audio_format_version,
    :audio_codec_id,
    :audio_codec_id_hint,
    :audio_codec_info,
    :audio_channel_positions,
    :audio_channels,
    :audio_encoded_date,
    :audio_tagged_date,

    ### IMAGE
    
    :image_resolution,
    :image_format,

    :image_width,
    :image_height,
    
    ### MENU
    
    :menu_stream_id,
    :menu_tagged_date,
    :menu_encoded_date,
    :menu_delay,
    
    ### TEXT
    :text_codec_id,
    :text_codec_info,
    :text_format,
    :text_stream_id
  ]
  
  Mediainfo.supported_attributes.each do |attribute|
    test "supports #{attribute} attribute" do
      assert supported_attributes.include?(attribute),
        "#{attribute} is not supported"
    end
  end
  
  def setup
    Mediainfo.default_mediainfo_path!
  end
  
  test "retains last system command generated" do
    p = File.expand_path "./test/fixtures/dinner.3g2.xml"
    m = Mediainfo.new p
    assert_equal "mediainfo \"#{p}\" --Output=XML", m.last_command
  end
  
  test "allows customization of path to mediainfo binary" do
    Mediainfo.any_instance.stubs(:run_command!).returns("test")
    
    assert_equal "mediainfo", Mediainfo.path
    
    m = Mediainfo.new "/dev/null"
    assert_equal "mediainfo \"/dev/null\" --Output=XML", m.last_command
    
    Mediainfo.any_instance.stubs(:mediainfo_version).returns("0.7.25")
    
    Mediainfo.path = "/opt/local/bin/mediainfo"
    assert_equal "/opt/local/bin/mediainfo", Mediainfo.path
    
    m = Mediainfo.new "/dev/null"
    assert_equal "/opt/local/bin/mediainfo \"/dev/null\" --Output=XML", m.last_command
  end
  
  test "can be initialized with a raw response" do
    m = Mediainfo.new
    m.raw_response = mediainfo_fixture("AwayWeGo_24fps.mov")
    assert m.video?
    assert m.audio?
  end
  
  test "cannot be initialized with version < 0.7.25" do
    Mediainfo.any_instance.stubs(:mediainfo_version).returns("0.7.10")
    assert_raises(Mediainfo::IncompatibleVersionError) { Mediainfo.new }
  end
  
  test "fails obviously when CLI is not installed" do
    Mediainfo.any_instance.stubs(:mediainfo_version).returns(nil)
    assert_raises(Mediainfo::UnknownVersionError) { Mediainfo.new }
  end
end
