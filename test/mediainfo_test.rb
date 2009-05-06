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
    :video_format,
    :video_format_profile,
    :video_format_version,
    :video_format_settings_cabac,
    :video_format_settings_reframes,
    :video_format_settings_matrix,
    :video_codec_id,
    :video_codec_info,
    :video_frame_rate,
    :video_frame_rate_mode,
    :video_display_aspect_ratio,
    :video_bits_pixel_frame,
    :video_width,
    :video_height,
    :video_encoded_date,
    :video_tagged_date,

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
    :audio_format_settings_endianness,
    :audio_format_settings_sign,
    :audio_codec_id,
    :audio_codec_info,
    :audio_channel_positions,
    :audio_channels,
    :audio_encoded_date,
    :audio_tagged_date,

    ### IMAGE
    
    :image_resolution,
    :image_format,

    :image_width,
    :image_height
  ]
  
  supported_attributes.each do |attribute|
    test "supports #{attribute} attribute" do
      assert Mediainfo.supported_attributes.include?(attribute),
        "#{attribute} is not supported"
    end
  end
end
