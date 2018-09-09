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

  describe '.from' do

    it 'a file' do
      # This file is ignored by git
      fixture = './spec/fixtures/video/sample.3gp'

      # Download the video sample file unless it exists
      unless File.exist?(fixture)
        Net::HTTP.start('techslides.com') { |http|
          resp = http.get('/demos/sample-videos/small.3gp')
          open(fixture, 'wb') { |file|
            file.write(resp.body)
          }
        }
      end

      # REXML
      expect{MediaInfo.from(nil)}.to raise_error(MediaInfo::BadInputError)
      expect{MediaInfo.from('test')}.to raise_error(MediaInfo::BadInputError)
      expect{MediaInfo.from(fixture)}.not_to raise_error # Make sure we can load a file from the current dir
      expect(MediaInfo.from(fixture)).to be_an_instance_of(MediaInfo::Tracks)
      expect(MediaInfo.from(fixture).xml.include?('?xml')).to be true
      # NOKOGIRI
      ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
      expect{MediaInfo.from(fixture)}.not_to raise_error
      expect(MediaInfo.from(fixture)).to be_an_instance_of(MediaInfo::Tracks)
      expect(MediaInfo.from(fixture).xml.include?('?xml')).to be true
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

    it 'a url' do
      ok_http_url = 'http://techslides.com/demos/sample-videos/small.mp4'
      ok_https_url = 'https://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4'
      nok_url = 'http://urlthatdoesnotexist.unknown/file.mov'

      expect{MediaInfo.from(ok_http_url)}.not_to raise_error
      expect{MediaInfo.from(nok_url)}.to raise_error(SocketError)
      expect(MediaInfo.from(ok_http_url)).to be_an_instance_of(MediaInfo::Tracks)
      expect(MediaInfo.from(ok_https_url)).to be_an_instance_of(MediaInfo::Tracks)
      expect(MediaInfo.from(ok_http_url).xml.include?('?xml')).to be true
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

    it 'raw xml' do
      expect{MediaInfo.from(::File.open('./spec/fixtures/xml/hats.3gp.xml').read)}.not_to raise_error
      expect(MediaInfo.from(::File.open('./spec/fixtures/xml/hats.3gp.xml').read)).to be_an_instance_of(MediaInfo::Tracks)
      expect(MediaInfo.from(::File.open('./spec/fixtures/xml/hats.3gp.xml').read).xml.include?('?xml')).to be true
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

    it 'generates track types' do
      # REXML
      ## URL
      expect{MediaInfo.from('http://techslides.com/demos/sample-videos/small.mp4').video.bitrate}.not_to raise_error
      expect(MediaInfo.from('http://techslides.com/demos/sample-videos/small.mp4').video.bitratetest).to eq(nil)
      ## XML
      ### Stream/OtherType ID
      expect{MediaInfo.from(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).other2.duration}.not_to raise_error
      expect{MediaInfo.from(::File.open('./spec/fixtures/xml/multiple_streams_with_stream_id.xml').read).video2.bitrate}.not_to raise_error
      ### No Stream ID + Three video streams
      expect{MediaInfo.from(::File.open('./spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml').read).video6.bitrate}.not_to raise_error
      # NOKOGIRI
      ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
      ## Stream ID
      expect{MediaInfo.from(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).other2.duration}.not_to raise_error
      expect{MediaInfo.from(::File.open('./spec/fixtures/xml/multiple_streams_with_stream_id.xml').read).video.bitrate}.not_to raise_error
      ## No Stream ID + Three video streams
      expect{MediaInfo.from(::File.open('./spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml').read).video100.bitrate}.not_to raise_error
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

  end

  describe 'Tracks Type' do

    it 'support ?' do
      # REXML
      expect(MediaInfo.from(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).other?).to eq(true)
      expect(MediaInfo.from(::File.open('./spec/fixtures/xml/multiple_streams_with_stream_id.xml').read).video2?).to eq(true)
      expect(MediaInfo.from('http://techslides.com/demos/sample-videos/small.mp4').image?).to be_falsey
      # NOKOGIRI
      ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
      expect(MediaInfo.from(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).other?).to eq(true)
      expect(MediaInfo.from(::File.open('./spec/fixtures/xml/multiple_streams_with_stream_id.xml').read).video5?).to be_falsey
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

    it 'support .count' do
      # REXML
      expect(MediaInfo.from(::File.open('./spec/fixtures/xml/subtitle.xml').read).text.count).to eq(4)
      expect(MediaInfo.from(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).audio.count).to eq(1)
      expect(MediaInfo.from(::File.open('./spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml').read).video.count).to eq(3)
      expect(MediaInfo.from('http://techslides.com/demos/sample-videos/small.mp4').video.count).to eq(1)
      # NOKOGIRI
      ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
      expect(MediaInfo.from(::File.open('./spec/fixtures/xml/subtitle.xml').read).text3.count).to eq(1)
      expect(MediaInfo.from(::File.open('./spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml').read).video6.count).to eq(1)
      expect(MediaInfo.from('http://techslides.com/demos/sample-videos/small.mp4').video.count).to eq(1)
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

    it 'support <extra>' do
      # REXML
      expect(MediaInfo.from(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).general.extra).to_not be(nil)
      expect(MediaInfo.from(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).general.extra.com_apple_quicktime_make).to eq('Apple')
      # NOKOGIRI
      ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
      expect(MediaInfo.from(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).general.extra).to_not be(nil)
      expect(MediaInfo.from(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).general.extra.com_apple_quicktime_software).to eq('11.2.6')
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

    describe 'Attribute' do

      it 'name standardization' do
        # REXML
        expect(MediaInfo.from(::File.open('./spec/fixtures/xml/AwayWeGo_24fps.mov.xml').read).video.bit_rate).to be(nil)
        expect(MediaInfo.from(::File.open('./spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml').read).video.framerate).to_not be(nil)
        # NOKOGIRI
        ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
        expect(MediaInfo.from(::File.open('./spec/fixtures/xml/Broken Embraces_510_780_576x432.mp4.xml').read).video.bitrate).to_not be(nil)
        expect(MediaInfo.from(::File.open('./spec/fixtures/xml/omen1976_464_0_480x336-6.jpg.xml').read).general.file_size).to be(nil)
        ENV['MEDIAINFO_XML_PARSER'] = nil
      end

      it 'strings with float or integer are converted with to_f or to_i respectively' do
        # REXML
        expect(MediaInfo.from(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).general.extra.com_apple_quicktime_software).to eq('11.2.6') # Check that two or more dots remain strings
        expect(MediaInfo.from(::File.open('./spec/fixtures/xml/vimeo.57652.avi.xml').read).video.bits__pixel_frame_).to be_a(Float)
        expect(MediaInfo.from(::File.open('./spec/fixtures/xml/vimeo.57652.avi.xml').read).video.id).to be_a(Integer)
        expect(MediaInfo.from(::File.open('./spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml').read).video.bitrate).to_not be_a(Float)
        # NOKOGIRI
        ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
        expect(MediaInfo.from(::File.open('./spec/fixtures/xml/hats.3gp.xml').read).video.colorimetry).to eq('4:2:0')
        expect(MediaInfo.from(::File.open('./spec/fixtures/xml/AwayWeGo_24fps.mov.xml').read).video.display_aspect_ratio).to be_a(String)
        expect(MediaInfo.from(::File.open('./spec/fixtures/xml/Broken Embraces_510_780_576x432.mp4.xml').read).audio.codec_id).to be_a(Integer)
        ENV['MEDIAINFO_XML_PARSER'] = nil
      end

      it 'Duration is converted to milliseconds' do
        # REXML
        # TODO (see tracks.rb under standardize_to_milliseconds) expect(MediaInfo.obtain(::File.open('./spec/fixtures/xml/iphone6+_video.mov.xml').read).video.duration).to be_a(Integer)
        expect(MediaInfo.from(::File.open('./spec/fixtures/xml/AwayWeGo_24fps.mov.xml').read).video.duration).to be_a(Integer)
        expect(MediaInfo.from(::File.open('./spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml').read).video100.duration).to eq(4170)
        # NOKOGIRI
        ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
        expect(MediaInfo.from(::File.open('./spec/fixtures/xml/hats.3gp.xml').read).video.duration).to be_a(Integer)
        expect(MediaInfo.from(::File.open('./spec/fixtures/xml/vimeo.57652.avi.xml').read).video.duration).to eq(15164)
        ENV['MEDIAINFO_XML_PARSER'] = nil
      end

    end

  end

  describe 'Fixtures' do

    it './spec/fixtures/xml/AwayWeGo_24fps.mov.xml' do
      fixture = './spec/fixtures/xml/AwayWeGo_24fps.mov.xml'
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.from(::File.open(fixture).read).track_types.any?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).general?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).video?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).audio?).to be true
      end
    end

    it './spec/fixtures/xml/Broken Embraces_510_780_576x432.mp4.xml' do
      fixture = './spec/fixtures/xml/Broken Embraces_510_780_576x432.mp4.xml'
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.from(::File.open(fixture).read).track_types.any?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).general?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).video?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).audio?).to be true
      end
    end

    it './spec/fixtures/xml/dinner.3g2.xml' do
      fixture = './spec/fixtures/xml/dinner.3g2.xml'
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.from(::File.open(fixture).read).track_types.any?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).general?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).video?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).audio?).to be true
      end
    end

    it './spec/fixtures/xml/hats.3gp.xml' do
      fixture = './spec/fixtures/xml/hats.3gp.xml'
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.from(::File.open(fixture).read).track_types.any?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).general?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).video?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).audio?).to be true
      end
    end

    it './spec/fixtures/xml/iphone6+_video.mov.xml' do
      fixture = './spec/fixtures/xml/iphone6+_video.mov.xml'
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.from(::File.open(fixture).read).track_types.any?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).general?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).video?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).audio?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).other.count).to eq(2)
      end
    end

    it './spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml' do
      fixture = './spec/fixtures/xml/multiple_streams_no_stream_id_three_video.xml'
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.from(::File.open(fixture).read).track_types.any?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).general?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).video?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).audio?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).video.count).to eq(3)
      end
    end

    it './spec/fixtures/xml/omen1976_464_0_480x336-6.jpg.xml' do
      fixture = './spec/fixtures/xml/omen1976_464_0_480x336-6.jpg.xml'
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.from(::File.open(fixture).read).track_types.any?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).image?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).image.count).to eq(1)
      end
    end

    it './spec/fixtures/xml/vimeo.57652.avi.xml' do
      fixture = './spec/fixtures/xml/vimeo.57652.avi.xml'
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.from(::File.open(fixture).read).track_types.any?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).general?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).video?).to be true
        expect(MediaInfo.from(::File.open(fixture).read).audio?).to be true
      end
    end

  end

end
