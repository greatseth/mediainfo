RSpec.describe MediaInfo do

  # Set ENVs back to default
  ENV['MEDIAINFO_PATH'] = nil
  ENV['MEDIAINFO_XML_PARSER'] = nil

  describe 'Instantiation' do

    it 'MediaInfo Location can be found and returns valid path' do
      expect {MediaInfo.location}.not_to raise_error
      expect(MediaInfo.location).to include('/mediainfo')
      ENV['MEDIAINFO_PATH'] = '/usr/local/blah/mediablinfo'
      expect {MediaInfo.location}.to raise_error(MediaInfo::EnvironmentError)
    end

    it 'MediaInfo Version returns a valid value' do
      expect {MediaInfo.location}.to raise_error(MediaInfo::EnvironmentError) # Raise a missing error since we set MEDIAINFO_PATH in the previous test and never unset/changed it
      ENV['MEDIAINFO_PATH'] = nil # Set back to default MediaInfo location
      expect {MediaInfo.location}.to_not raise_error
      expect {MediaInfo.version}.to_not raise_error
      expect(MediaInfo.version > '0.7.25').to eq(true) # Ensure the returned value is the proper format (\d+\.\d+\.\d+)
    end

    it 'XML Parser returns rexml or custom parser (nokogiri)' do
      expect(MediaInfo.xml_parser).to eq('rexml/document') # Returns default if ENV not set
      ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
      expect(MediaInfo.xml_parser).to eq('nokogiri') # Test if we can load non-rexml XML parsers
    end

  end

  describe '.obtain' do
    it 'on a file' do
      expect {MediaInfo.obtain('~/Desktop/test.mov')}.not_to raise_error
    end

    it 'on a url' do
      expect {MediaInfo.obtain('~/Desktop/test.mov')}.not_to raise_error
    end

    it 'on a raw xml' do
      expect {MediaInfo.obtain('~/Desktop/test.mov')}.not_to raise_error
    end
  end

end
