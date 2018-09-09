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
