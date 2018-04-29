RSpec.describe MediaInfo do

  # Set ENVs back to default
  ENV['MEDIAINFO_PATH'] = nil
  ENV['MEDIAINFO_XML_PARSER'] = nil

  describe 'Instantiation' do

    it 'MediaInfo Location can be found and returns valid path + raises error if not valid path' do
      expect{MediaInfo.location}.not_to raise_error
      expect(MediaInfo.location).to include('/mediainfo')
      ENV['MEDIAINFO_PATH'] = '/usr/local/blah/mediablinfo'
      expect {MediaInfo.location}.to raise_error(MediaInfo::EnvironmentError)
    end

    it 'MediaInfo Version returns a valid value' do
      expect{MediaInfo.location}.to raise_error(MediaInfo::EnvironmentError) # Raise a missing error since we set MEDIAINFO_PATH in the previous test and never unset/changed it
      ENV['MEDIAINFO_PATH'] = nil # Set back to default MediaInfo location
      expect{MediaInfo.location}.to_not raise_error
      expect{MediaInfo.version}.to_not raise_error
      expect(MediaInfo.version > '0.7.25').to eq(true) # Ensure the returned value is the proper format (\d+\.\d+\.\d+)
    end

    it 'XML Parser returns rexml or custom parser (nokogiri)' do
      expect(MediaInfo.xml_parser).to eq('rexml/document') # Returns default if ENV not set
      ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
      expect(MediaInfo.xml_parser).to eq('nokogiri') # Test if we can load non-rexml XML parsers
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

  end

  describe '.obtain' do

    it 'on a file' do # Requires a test file on Desktop
      # REXML
      expect{MediaInfo.obtain('~/Desktop/test.mov')}.not_to raise_error
      expect(MediaInfo.obtain('~/Desktop/test.mov')).to be_an_instance_of(MediaInfo::Tracks)
      expect(MediaInfo.obtain('~/Desktop/test.mov').xml.include?('?xml')).to be true
      # NOKOGIRI
      ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
      expect{MediaInfo.obtain('~/Desktop/test.mov')}.not_to raise_error
      expect(MediaInfo.obtain('~/Desktop/test.mov')).to be_an_instance_of(MediaInfo::Tracks)
      expect(MediaInfo.obtain('~/Desktop/test.mov').xml.include?('?xml')).to be true
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

    it 'on a url' do
      expect{MediaInfo.obtain('http://techslides.com/demos/sample-videos/small.mp4')}.not_to raise_error
      expect{MediaInfo.obtain('http://urlthatdoesnotexist/file.mov')}.to raise_error(SocketError)
      expect(MediaInfo.obtain('http://techslides.com/demos/sample-videos/small.mp4')).to be_an_instance_of(MediaInfo::Tracks)
      expect(MediaInfo.obtain('http://techslides.com/demos/sample-videos/small.mp4').xml.include?('?xml')).to be true
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

    it 'on a raw xml' do
      expect{MediaInfo.obtain(::File.open('./spec/fixtures/xml/hats.3gp.xml').read)}.not_to raise_error
      expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/hats.3gp.xml').read)).to be_an_instance_of(MediaInfo::Tracks)
      expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/hats.3gp.xml').read).xml.include?('?xml')).to be true
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

    it 'generates track types' do
      # REXML
      ## URL
      expect{MediaInfo.obtain('http://techslides.com/demos/sample-videos/small.mp4').video.bitrate}.not_to raise_error
      expect{MediaInfo.obtain('http://techslides.com/demos/sample-videos/small.mp4').video.bit_rate}.to raise_error(NoMethodError)
      ## XML
      ### Stream/OtherType ID
      expect{MediaInfo.obtain(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).other2.duration}.not_to raise_error
      expect{MediaInfo.obtain(::File.open('./spec/fixtures/xml/multiple_streams_with_stream_id.xml').read).video2.bit_rate}.not_to raise_error
      ### No Stream ID + Three video streams
      expect{MediaInfo.obtain(::File.open('./spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml').read).video2.bit_rate}.not_to raise_error
      # NOKOGIRI
      ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
      ## Stream ID
      expect{MediaInfo.obtain(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).other2.duration}.not_to raise_error
      expect{MediaInfo.obtain(::File.open('./spec/fixtures/xml/multiple_streams_with_stream_id.xml').read).video.bit_rate}.not_to raise_error
      ## No Stream ID + Three video streams
      expect{MediaInfo.obtain(::File.open('./spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml').read).video3.bit_rate}.not_to raise_error
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

    describe 'tracks types' do
      it 'support ?' do
        # REXML
        expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).other?).to eq(true)
        expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/multiple_streams_with_stream_id.xml').read).video2?).to eq(true)
        expect(MediaInfo.obtain('http://techslides.com/demos/sample-videos/small.mp4').image?).to be_falsey
        # NOKOGIRI
        ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
        expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).other?).to eq(true)
        expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/multiple_streams_with_stream_id.xml').read).video5?).to be_falsey
        ENV['MEDIAINFO_XML_PARSER'] = nil
      end


    end

  end

end
