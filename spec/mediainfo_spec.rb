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
      expect(MediaInfo.obtain('http://techslides.com/demos/sample-videos/small.mp4').video.bitratetest).to eq(nil)
      ## XML
      ### Stream/OtherType ID
      expect{MediaInfo.obtain(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).other2.duration}.not_to raise_error
      expect{MediaInfo.obtain(::File.open('./spec/fixtures/xml/multiple_streams_with_stream_id.xml').read).video2.bitrate}.not_to raise_error
      ### No Stream ID + Three video streams
      expect{MediaInfo.obtain(::File.open('./spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml').read).video6.bitrate}.not_to raise_error
      # NOKOGIRI
      ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
      ## Stream ID
      expect{MediaInfo.obtain(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).other2.duration}.not_to raise_error
      expect{MediaInfo.obtain(::File.open('./spec/fixtures/xml/multiple_streams_with_stream_id.xml').read).video.bitrate}.not_to raise_error
      ## No Stream ID + Three video streams
      expect{MediaInfo.obtain(::File.open('./spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml').read).video100.bitrate}.not_to raise_error
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

  end

  describe 'Tracks Type' do

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

    it 'support .count' do
      # REXML
      expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/subtitle.xml').read).text.count).to eq(4)
      expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).audio.count).to eq(1)
      expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml').read).video.count).to eq(3)
      expect(MediaInfo.obtain('http://techslides.com/demos/sample-videos/small.mp4').video.count).to eq(1)
      # NOKOGIRI
      ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
      expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/subtitle.xml').read).text3.count).to eq(1)
      expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml').read).video6.count).to eq(1)
      expect(MediaInfo.obtain('http://techslides.com/demos/sample-videos/small.mp4').video.count).to eq(1)
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

    it 'support <extra>' do
      # REXML
      expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).general.extra).to_not be(nil)
      expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).general.extra.com_apple_quicktime_make).to eq('Apple')
      # NOKOGIRI
      ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
      expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).general.extra).to_not be(nil)
      expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).general.extra.com_apple_quicktime_software).to eq('11.2.6')
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

    describe 'Attribute' do

      it 'name standardization' do
        # REXML
        expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/AwayWeGo_24fps.mov.xml').read).video.bit_rate).to be(nil)
        expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml').read).video.framerate).to_not be(nil)
        # NOKOGIRI
        ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
        expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/Broken Embraces_510_780_576x432.mp4.xml').read).video.bitrate).to_not be(nil)
        expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/omen1976_464_0_480x336-6.jpg.xml').read).general.file_size).to be(nil)
        ENV['MEDIAINFO_XML_PARSER'] = nil
      end

      it 'strings with float or integer are converted with to_f or to_i respectively' do
        # REXML
        expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).general.extra.com_apple_quicktime_software).to eq('11.2.6') # Check that two or more dots remain strings
        expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/vimeo.57652.avi.xml').read).video.bits__pixel_frame_).to be_a(Float)
        expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/vimeo.57652.avi.xml').read).video.id).to be_a(Integer)
        expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml').read).video.bitrate).to_not be_a(Float)
        # NOKOGIRI
        ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
        expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/hats.3gp.xml').read).video.colorimetry).to eq('4:2:0')
        expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/AwayWeGo_24fps.mov.xml').read).video.display_aspect_ratio).to be_a(String)
        expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/Broken Embraces_510_780_576x432.mp4.xml').read).audio.codec_id).to be_a(Integer)
        ENV['MEDIAINFO_XML_PARSER'] = nil
      end

      it 'Duration is converted to milliseconds' do
        # REXML
        # TODO (see tracks.rb under standardize_to_milliseconds) expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).video.duration).to be_a(Integer)
        expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/AwayWeGo_24fps.mov.xml').read).video.duration).to be_a(Integer)
        expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml').read).video100.duration).to eq(10204000)
        # NOKOGIRI
        ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
        expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/hats.3gp.xml').read).video.duration).to be_a(Integer)
        expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/vimeo.57652.avi.xml').read).video.duration).to eq(9855000)
        ENV['MEDIAINFO_XML_PARSER'] = nil
      end

    end

  end

  describe 'Fixtures' do

    it './spec/fixtures/xml/AwayWeGo_24fps.mov.xml' do # Requires a test file on Desktop
      fixture = './spec/fixtures/xml/AwayWeGo_24fps.mov.xml'
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.obtain(::File.open(fixture).read).track_types.any?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).general?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).video?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).audio?).to be true
      end
    end

    it './spec/fixtures/xml/Broken Embraces_510_780_576x432.mp4.xml' do # Requires a test file on Desktop
      fixture = './spec/fixtures/xml/Broken Embraces_510_780_576x432.mp4.xml'
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.obtain(::File.open(fixture).read).track_types.any?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).general?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).video?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).audio?).to be true
      end
    end

    it './spec/fixtures/xml/dinner.3g2.xml' do # Requires a test file on Desktop
      fixture = './spec/fixtures/xml/dinner.3g2.xml'
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.obtain(::File.open(fixture).read).track_types.any?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).general?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).video?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).audio?).to be true
      end
    end

    it './spec/fixtures/xml/hats.3gp.xml' do # Requires a test file on Desktop
      fixture = './spec/fixtures/xml/hats.3gp.xml'
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.obtain(::File.open(fixture).read).track_types.any?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).general?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).video?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).audio?).to be true
      end
    end

    it './spec/fixtures/xml/iphone6+_video.mov.xml' do # Requires a test file on Desktop
      fixture = './spec/fixtures/xml/iphone6+_video.mov.xml'
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.obtain(::File.open(fixture).read).track_types.any?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).general?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).video?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).audio?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).other.count).to eq(2)
      end
    end

    it './spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml' do # Requires a test file on Desktop
      fixture = './spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml'
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.obtain(::File.open(fixture).read).track_types.any?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).general?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).video?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).audio?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).video.count).to eq(3)
      end
    end

    it './spec/fixtures/xml/omen1976_464_0_480x336-6.jpg.xml' do # Requires a test file on Desktop
      fixture = './spec/fixtures/xml/omen1976_464_0_480x336-6.jpg.xml'
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.obtain(::File.open(fixture).read).track_types.any?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).image?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).image.count).to eq(1)
      end
    end

    it './spec/fixtures/xml/vimeo.57652.avi.xml' do # Requires a test file on Desktop
      fixture = './spec/fixtures/xml/vimeo.57652.avi.xml'
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.obtain(::File.open(fixture).read).track_types.any?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).general?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).video?).to be true
        expect(MediaInfo.obtain(::File.open(fixture).read).audio?).to be true
      end
    end

  end

end
