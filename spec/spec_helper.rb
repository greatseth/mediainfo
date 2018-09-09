require 'bundler/setup'
require 'mediainfo'

RSpec.shared_context 'Shared variables' do
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
    let(:xml_files_path) { xml_files_path }

    # Retrieve all xml files content so they are opened once
    xml_files_content = {}
    xml_files_path.each do |key, path|
      xml_files_content[key] = File.open(path).read
    end
    let(:xml_files_content) { xml_files_content }

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
    let(:http_invalid_url) { 'http://urlthatdoesnotexist/file.mov' }
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include_context 'Shared variables'
end
