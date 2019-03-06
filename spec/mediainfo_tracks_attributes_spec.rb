RSpec.describe MediaInfo::Tracks::Attributes do

  # TODO
  # Add more contexts and direct tests for .sanitize_element_value
  describe '.sanitize_element_value class method' do

    context 'when the chosen parser (MEDIAINFO_XML_PARSER) is the default one' do

      it 'standardizes the names correctly' do
        expect(MediaInfo.from(xml_files_content[:sample_mov]).video.bit_rate).to be(nil)
        expect(MediaInfo.from(xml_files_content[:multiple_streams_no_id]).video.framerate).to_not be(nil)
      end

      context 'when the submitted value is a string with a Float value' do
        it 'converts it to Float' do
          expect(MediaInfo.from(xml_files_content[:sample_avi]).video.bits__pixel_frame_).to be_a(Float)
        end
      end

      context 'when the submitted value is a string with a Integer value' do
        it 'converts it to Integer' do
          expect(MediaInfo.from(xml_files_content[:sample_avi]).video.id).to be_a(Integer)
        end
      end

      context 'when the submitted value is a string with a String value' do
        it 'remains a String' do
          expect(MediaInfo.from(xml_files_content[:sample_iphone_mov]).general.extra.com_apple_quicktime_software).to eq('11.2.6')
          expect(MediaInfo.from(xml_files_content[:multiple_streams_no_id]).video.bitrate).to_not be_a(Float)
        end
      end

    end

    context 'when the chosen parser (MEDIAINFO_XML_PARSER) is nokogiri' do
      include_context 'sets MEDIAINFO_XML_PARSER to nokogiri'

      it 'standardizes the names correctly' do
        expect(MediaInfo.from(xml_files_content[:sample_mp4]).video.bitrate).to_not be(nil)
        expect(MediaInfo.from(xml_files_content[:sample_jpg]).general.file_size).to be(nil)
      end

      context 'when the submitted value is a string with a Float value' do
        it 'converts it to Float' do
          expect(MediaInfo.from(xml_files_content[:sample_avi]).video.bits__pixel_frame_).to be_a(Float)
        end
      end

      context 'when the submitted value is a string with a Integer value' do
        it 'converts it to Integer' do
          expect(MediaInfo.from(xml_files_content[:sample_mp4]).audio.codec_id).to be_a(Integer)
        end
      end

      context 'when the submitted value is a string with a String value' do
        it 'remains a String' do
          expect(MediaInfo.from(xml_files_content[:sample_3gp]).video.colorimetry).to eq('4:2:0')
          expect(MediaInfo.from(xml_files_content[:sample_mov]).video.display_aspect_ratio).to be_a(String)
        end
      end
    end

  end

  describe '.standardize_to_milliseconds class method' do
    context 'when submitted a String structured value' do
      it 'converts it to milliseconds' do
        expect(MediaInfo.from(xml_files_content[:sample_mov]).video.duration).to be_a(Integer)
        expect(MediaInfo.from(xml_files_content[:multiple_streams_no_id]).video100.duration).to eq(4170)
        expect(MediaInfo.from(xml_files_content[:sample_3gp]).video.duration).to be_a(Integer)
        expect(MediaInfo.from(xml_files_content[:sample_avi]).video.duration).to eq(15164)
      end
    end

    context 'when submitted a Float structured value' do
      it 'converts it to milliseconds' do
        expect(MediaInfo.from(xml_files_content[:sample_iphone_mov]).video.duration).to be_a(Integer)
        expect(MediaInfo.from(xml_files_content[:sample_iphone_mov]).video.duration).to eq(194243)
      end
    end

  end

end
