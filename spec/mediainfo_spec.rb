RSpec.describe MediaInfo do

  # Set ENVs back to default
  ENV['MEDIAINFO_PATH'] = nil
  ENV['MEDIAINFO_XML_PARSER'] = nil

  # Listing of files path
  base_local_path = './spec/fixtures/'

  # Retrieve all xml files path
  base_local_xml_path = "#{base_local_path}xml/"
  xml_files_path = {}
  Dir.glob("#{base_local_xml_path}*").each do |filename|
    filename.gsub!(/^\..*\//, '')
    key = filename.gsub(/\..*$/, '').to_sym
    xml_files_path[key] = [base_local_xml_path, filename].join('/')
  end

  # Retrieve all xml files content
  xml_files_content = {}
  xml_files_path.each do |key, path|
    xml_files_content[key] = File.open(path).read
  end


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
      expect{MediaInfo.from('test')}.to raise_error(ArgumentError)
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
      expect{MediaInfo.from('http://techslides.com/demos/sample-videos/small.mp4')}.not_to raise_error
      expect{MediaInfo.from('http://urlthatdoesnotexist/file.mov')}.to raise_error(SocketError)
      expect(MediaInfo.from('http://techslides.com/demos/sample-videos/small.mp4')).to be_an_instance_of(MediaInfo::Tracks)
      expect(MediaInfo.from('http://techslides.com/demos/sample-videos/small.mp4').xml.include?('?xml')).to be true
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

    it 'raw xml' do
      expect{MediaInfo.from(xml_files_content[:sample_3gp])}.not_to raise_error
      expect(MediaInfo.from(xml_files_content[:sample_3gp])).to be_an_instance_of(MediaInfo::Tracks)
      expect(MediaInfo.from(xml_files_content[:sample_3gp]).xml.include?('?xml')).to be true
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

    it 'generates track types' do
      # REXML
      ## URL
      expect{MediaInfo.from('http://techslides.com/demos/sample-videos/small.mp4').video.bitrate}.not_to raise_error
      expect(MediaInfo.from('http://techslides.com/demos/sample-videos/small.mp4').video.bitratetest).to eq(nil)
      ## XML
      ### Stream/OtherType ID
      expect{MediaInfo.from(xml_files_content[:sample_iphone_mov]).other2.duration}.not_to raise_error
      expect{MediaInfo.from(xml_files_content[:multiple_streams_with_id]).video2.bitrate}.not_to raise_error
      ### No Stream ID + Three video streams
      expect{MediaInfo.from(xml_files_content[:multiple_streams_no_id]).video6.bitrate}.not_to raise_error
      # NOKOGIRI
      ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
      ## Stream ID
      expect{MediaInfo.from(xml_files_content[:sample_iphone_mov]).other2.duration}.not_to raise_error
      expect{MediaInfo.from(xml_files_content[:multiple_streams_with_id]).video.bitrate}.not_to raise_error
      ## No Stream ID + Three video streams
      expect{MediaInfo.from(xml_files_content[:multiple_streams_no_id]).video100.bitrate}.not_to raise_error
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

  end

  describe 'Tracks Type' do

    it 'support ?' do
      # REXML
      expect(MediaInfo.from(xml_files_content[:sample_iphone_mov]).other?).to eq(true)
      expect(MediaInfo.from(xml_files_content[:multiple_streams_with_id]).video2?).to eq(true)
      expect(MediaInfo.from('http://techslides.com/demos/sample-videos/small.mp4').image?).to be_falsey
      # NOKOGIRI
      ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
      expect(MediaInfo.from(xml_files_content[:sample_iphone_mov]).other?).to eq(true)
      expect(MediaInfo.from(xml_files_content[:multiple_streams_with_id]).video5?).to be_falsey
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

    it 'support .count' do
      # REXML
      expect(MediaInfo.from(xml_files_content[:subtitle]).text.count).to eq(4)
      expect(MediaInfo.from(xml_files_content[:sample_iphone_mov]).audio.count).to eq(1)
      expect(MediaInfo.from(xml_files_content[:multiple_streams_no_id]).video.count).to eq(3)
      expect(MediaInfo.from('http://techslides.com/demos/sample-videos/small.mp4').video.count).to eq(1)
      # NOKOGIRI
      ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
      expect(MediaInfo.from(xml_files_content[:subtitle]).text3.count).to eq(1)
      expect(MediaInfo.from(xml_files_content[:multiple_streams_no_id]).video6.count).to eq(1)
      expect(MediaInfo.from('http://techslides.com/demos/sample-videos/small.mp4').video.count).to eq(1)
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

    it 'support <extra>' do
      # REXML
      expect(MediaInfo.from(xml_files_content[:sample_iphone_mov]).general.extra).to_not be(nil)
      expect(MediaInfo.from(xml_files_content[:sample_iphone_mov]).general.extra.com_apple_quicktime_make).to eq('Apple')
      # NOKOGIRI
      ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
      expect(MediaInfo.from(xml_files_content[:sample_iphone_mov]).general.extra).to_not be(nil)
      expect(MediaInfo.from(xml_files_content[:sample_iphone_mov]).general.extra.com_apple_quicktime_software).to eq('11.2.6')
      ENV['MEDIAINFO_XML_PARSER'] = nil
    end

    describe 'Attribute' do

      it 'name standardization' do
        # REXML
        expect(MediaInfo.from(xml_files_content[:sample_mov]).video.bit_rate).to be(nil)
        expect(MediaInfo.from(xml_files_content[:multiple_streams_no_id]).video.framerate).to_not be(nil)
        # NOKOGIRI
        ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
        expect(MediaInfo.from(xml_files_content[:sample_mp4]).video.bitrate).to_not be(nil)
        expect(MediaInfo.from(xml_files_content[:sample_jpg]).general.file_size).to be(nil)
        ENV['MEDIAINFO_XML_PARSER'] = nil
      end

      it 'strings with float or integer are converted with to_f or to_i respectively' do
        # REXML
        expect(MediaInfo.from(xml_files_content[:sample_iphone_mov]).general.extra.com_apple_quicktime_software).to eq('11.2.6') # Check that two or more dots remain strings
        expect(MediaInfo.from(xml_files_content[:sample_avi]).video.bits__pixel_frame_).to be_a(Float)
        expect(MediaInfo.from(xml_files_content[:sample_avi]).video.id).to be_a(Integer)
        expect(MediaInfo.from(xml_files_content[:multiple_streams_no_id]).video.bitrate).to_not be_a(Float)
        # NOKOGIRI
        ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
        expect(MediaInfo.from(xml_files_content[:sample_3gp]).video.colorimetry).to eq('4:2:0')
        expect(MediaInfo.from(xml_files_content[:sample_mov]).video.display_aspect_ratio).to be_a(String)
        expect(MediaInfo.from(xml_files_content[:sample_mp4]).audio.codec_id).to be_a(Integer)
        ENV['MEDIAINFO_XML_PARSER'] = nil
      end

      it 'Duration is converted to milliseconds' do
        # REXML

        # TODO
        # expect(MediaInfo.from(xml_files_content[:sample_iphone_mov]).video.duration).to be_a(Integer)
        # expect(MediaInfo.from(xml_files_content[:sample_iphone_mov]).video.duration).to eq(194243)

        expect(MediaInfo.from(xml_files_content[:sample_mov]).video.duration).to be_a(Integer)
        expect(MediaInfo.from(xml_files_content[:multiple_streams_no_id]).video100.duration).to eq(4170)
        # NOKOGIRI
        ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
        expect(MediaInfo.from(xml_files_content[:sample_3gp]).video.duration).to be_a(Integer)
        expect(MediaInfo.from(xml_files_content[:sample_avi]).video.duration).to eq(15164)
        ENV['MEDIAINFO_XML_PARSER'] = nil
      end

    end

  end

  describe 'Fixtures' do

    it './spec/fixtures/xml/sample_mov.xml' do
      fixture = xml_files_content[:sample_mov]
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.from(fixture).track_types.any?).to be true
        expect(MediaInfo.from(fixture).general?).to be true
        expect(MediaInfo.from(fixture).video?).to be true
        expect(MediaInfo.from(fixture).audio?).to be true
      end
    end

    it './spec/fixtures/xml/sample_mp4.xml' do
      fixture = xml_files_content[:sample_mp4]
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.from(fixture).track_types.any?).to be true
        expect(MediaInfo.from(fixture).general?).to be true
        expect(MediaInfo.from(fixture).video?).to be true
        expect(MediaInfo.from(fixture).audio?).to be true
      end
    end

    it './spec/fixtures/xml/sample_3g2.xml' do
      fixture = xml_files_content[:sample_3g2]
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.from(fixture).track_types.any?).to be true
        expect(MediaInfo.from(fixture).general?).to be true
        expect(MediaInfo.from(fixture).video?).to be true
        expect(MediaInfo.from(fixture).audio?).to be true
      end
    end

    it './spec/fixtures/xml/sample_3gp.xml' do
      fixture = xml_files_content[:sample_3gp]
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.from(fixture).track_types.any?).to be true
        expect(MediaInfo.from(fixture).general?).to be true
        expect(MediaInfo.from(fixture).video?).to be true
        expect(MediaInfo.from(fixture).audio?).to be true
      end
    end

    it './spec/fixtures/xml/sample_iphone_mov.xml' do
      fixture = xml_files_content[:sample_iphone_mov]
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.from(fixture).track_types.any?).to be true
        expect(MediaInfo.from(fixture).general?).to be true
        expect(MediaInfo.from(fixture).video?).to be true
        expect(MediaInfo.from(fixture).audio?).to be true
        expect(MediaInfo.from(fixture).other.count).to eq(2)
      end
    end

    it './spec/fixtures/xml/multiple_streams_no_id.xml' do
      fixture = xml_files_content[:multiple_streams_no_id]
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.from(fixture).track_types.any?).to be true
        expect(MediaInfo.from(fixture).general?).to be true
        expect(MediaInfo.from(fixture).video?).to be true
        expect(MediaInfo.from(fixture).audio?).to be true
        expect(MediaInfo.from(fixture).video.count).to eq(3)
      end
    end

    it './spec/fixtures/xml/sample_jpg.xml' do
      fixture = xml_files_content[:sample_jpg]
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.from(fixture).track_types.any?).to be true
        expect(MediaInfo.from(fixture).image?).to be true
        expect(MediaInfo.from(fixture).image.count).to eq(1)
      end
    end

    it './spec/fixtures/xml/sample_avi.xml' do
      fixture = xml_files_content[:sample_avi]
      [nil,'nokogiri'].each do |xml_parser|
        ENV['MEDIAINFO_XML_PARSER'] = xml_parser
        expect(MediaInfo.from(fixture).track_types.any?).to be true
        expect(MediaInfo.from(fixture).general?).to be true
        expect(MediaInfo.from(fixture).video?).to be true
        expect(MediaInfo.from(fixture).audio?).to be true
      end
    end

  end

end
