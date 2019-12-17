# Shared variables

RSpec.shared_context 'Shared variables' do
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
    let(:xml_files_path) { xml_files_path }

    # Retrieve all xml files content so they are opened once
    xml_files_content = {}
    xml_files_path.each do |key, path|
      xml_files_content[key] = File.open(path).read
    end
    let(:xml_files_content) { xml_files_content }

    # Images'xml files
    let(:images_xml_files_content) {
      xml_files_content.select do |key, value|
        [:sample_jpg].include?(key)
      end
    }

    # Videos' xml files
    let(:videos_xml_files_content) {
      xml_files_content.select do |key, value|
        [
          :sample_3g2, :sample_3gp, :sample_avi, :sample_iphone_mov, :sample_mov,
          :sample_mp4, :multiple_streams_no_id, :multiple_streams_with_id
        ].include?(key)
      end
    }


    video_sample_path = './spec/fixtures/video/sample.3gp'
    let(:video_sample_path) { video_sample_path }

    # Download the video sample file (ignored by git) unless it already exists
    unless File.exist?(video_sample_path)
      Net::HTTP.start('techslides.com') { |http|
        resp = http.get('/demos/sample-videos/small.3gp')
        open(video_sample_path, 'wb') { |file|
          file.write(resp.body)
        }
      }
    end

    let(:http_valid_video_url) { 'http://techslides.com/demos/sample-videos/small.mp4' }
    # Using the S3 test for this instead let(:https_valid_video_url) { 'https://www.sample-videos.com/video123/mp4/240/big_buck_bunny_240p_1mb.mp4' }
    let(:http_invalid_url) { 'http://urlthatdoesnotexist/file.mov' }
end

# MEDIAINFO_PATH

RSpec.shared_context 'sets MEDIAINFO_PATH to invalid value' do
  mip = ENV['MEDIAINFO_PATH'] # Allows us to set MEDIAINFO_PATH back to what the user/env set it as
  before(:all) do
    ENV['MEDIAINFO_PATH'] = '/invalid/path/to/mediablinfo'
  end

  after(:all) do
    ENV['MEDIAINFO_PATH'] = mip
  end
end

RSpec.shared_context 'sets MEDIAINFO_PATH to a valid value' do
  mip = ENV['MEDIAINFO_PATH'] # Allows us to set MEDIAINFO_PATH back to what the user/env set it as
  before(:all) do
    ENV['MEDIAINFO_PATH'] = '/custom/path/mediainfo'
  end

  after(:all) do
    ENV['MEDIAINFO_PATH'] = mip
  end
end

# MEDIAINFO_XML_PARSER

RSpec.shared_context 'sets MEDIAINFO_XML_PARSER to nokogiri' do
  before(:all) do
    ENV['MEDIAINFO_XML_PARSER'] = 'nokogiri'
  end

  after(:all) do
    ENV['MEDIAINFO_XML_PARSER'] = nil
  end
end
