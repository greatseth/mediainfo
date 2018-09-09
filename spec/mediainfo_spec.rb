RSpec.describe MediaInfo do

  describe 'location class method' do

    context 'when the mediainfo bin path (MEDIAINFO_PATH) is valid' do
      include_context 'sets MEDIAINFO_PATH to default value'

      it 'does not raise an error' do
        expect{MediaInfo.location}.not_to raise_error
      end

      it 'returns the valid path' do
        expect(MediaInfo.location).to include('/mediainfo')
      end
    end

    context 'when the mediainfo bin path (MEDIAINFO_PATH) is not valid' do
      include_context 'sets MEDIAINFO_PATH to invalid value'

      it 'raises the correct error' do
        expect{MediaInfo.location}.to raise_error(MediaInfo::EnvironmentError)
      end
    end

  end

  # MediaInfo.version

  describe 'version class method' do

    context 'when the mediainfo bin path (MEDIAINFO_PATH) is valid' do
      include_context 'sets MEDIAINFO_PATH to default value'

      it 'does not raise an error' do
        expect{MediaInfo.version}.to_not raise_error
      end

      it 'returns the valid value' do
        # Ensure the returned value is the proper format (\d+\.\d+\.\d+)
        expect(MediaInfo.version > '0.7.25').to eq(true)
      end
    end

  end

  # MediaInfo.xml_parser

  describe 'xml_parser class method' do

    context 'when the chosen parser (MEDIAINFO_XML_PARSER) is the default one' do
      include_context 'sets MEDIAINFO_XML_PARSER to default value'

      it 'does not raise an error' do
        expect{MediaInfo.version}.to_not raise_error
      end

      it 'returns the name of the default parser' do
        expect(MediaInfo.xml_parser).to eq('rexml/document')
      end
    end

    context 'when the chosen parser (MEDIAINFO_XML_PARSER) is nokogiri' do
      include_context 'sets MEDIAINFO_XML_PARSER to nokogiri'

      it 'does not raise an error' do
        expect{MediaInfo.version}.to_not raise_error
      end

      it 'returns the name of the submitted valid parser (nokogiri)' do
        expect(MediaInfo.xml_parser).to eq('nokogiri')
      end
    end

  end

  # MediaInfo.from

  describe 'from class method' do

    shared_examples 'expected from class method for a file' do
      context 'when submitted a valid file path' do
        let(:input) { video_sample_path }

        it 'does not raise an error' do
          expect{MediaInfo.from(input)}.not_to raise_error
        end

        it 'returns an instance of MediaInfo::Tracks' do
          expect(MediaInfo.from(input)).to be_an_instance_of(MediaInfo::Tracks)
        end

        it 'returns an object with a valid xml output' do
          expect(MediaInfo.from(input).xml.include?('?xml')).to be true
        end
      end

      context 'when submitted an invalid file path' do
        let(:input) { 'invalid/file/path' }

        it 'raises the correct error' do
          expect{MediaInfo.from(input)}.to raise_error(ArgumentError)
        end
      end
    end

    shared_examples 'expected from class method for a url' do
      context 'when submitted a valid http valid url' do
        let(:input) { video_sample_path }

        it 'does not raise an error' do
          expect{MediaInfo.from(input)}.not_to raise_error
        end

        it 'returns an instance of MediaInfo::Tracks' do
          expect(MediaInfo.from(input)).to be_an_instance_of(MediaInfo::Tracks)
        end

        it 'returns an object with a valid xml output' do
          expect(MediaInfo.from(input).xml.include?('?xml')).to be true
        end
      end

      context 'when submitted a invalid http valid url' do
        let(:input) { http_invalid_url }

        it 'raises the correct error' do
          expect{MediaInfo.from(input)}.to raise_error(SocketError)
        end
      end
    end

    shared_examples 'expected from class method for raw xml' do
      context 'when submitted a valid raw xml' do
        let(:input) { xml_files_content[:sample_3gp] }

        it 'does not raise an error' do
          expect{MediaInfo.from(input)}.not_to raise_error
        end

        it 'returns an instance of MediaInfo::Tracks' do
          expect(MediaInfo.from(input)).to be_an_instance_of(MediaInfo::Tracks)
        end

        it 'returns an object with a valid xml output' do
          expect(MediaInfo.from(input).xml.include?('?xml')).to be true
        end
      end

      context 'when submitted a invalid raw xml' do
        let(:input) { 'invalid raw xml' }

        it 'raises the correct error' do
          expect{MediaInfo.from(input)}.to raise_error(ArgumentError)
        end
      end
    end

    shared_examples 'a valid MediaInfo::Tracks types generation' do

      # TODO
      # split these tests with a correct description for each
      #
      it 'does not raise an error when using a sample of methods' do
        expect{MediaInfo.from(http_valid_video_url).video.bitrate}.not_to raise_error
        expect(MediaInfo.from(http_valid_video_url).video.bitratetest).to eq(nil)

        expect{MediaInfo.from(xml_files_content[:sample_iphone_mov]).other2.duration}.not_to raise_error
        expect{MediaInfo.from(xml_files_content[:multiple_streams_with_id]).video2.bitrate}.not_to raise_error
        expect{MediaInfo.from(xml_files_content[:multiple_streams_no_id]).video6.bitrate}.not_to raise_error
      end
    end

    context 'when the chosen parser (MEDIAINFO_XML_PARSER) is the default one' do
      include_context 'sets MEDIAINFO_XML_PARSER to default value'

      it_behaves_like 'expected from class method for a file'
      it_behaves_like 'expected from class method for a url'
      it_behaves_like 'expected from class method for raw xml'
      it_behaves_like 'a valid MediaInfo::Tracks types generation'
    end

    context 'when the chosen parser (MEDIAINFO_XML_PARSER) is nokogiri' do
      include_context 'sets MEDIAINFO_XML_PARSER to nokogiri'

      it_behaves_like 'expected from class method for a file'
      it_behaves_like 'expected from class method for a url'
      it_behaves_like 'expected from class method for raw xml'
      it_behaves_like 'a valid MediaInfo::Tracks types generation'
    end

  end

end
