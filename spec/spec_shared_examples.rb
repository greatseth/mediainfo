# MediaInfo.from shared examples

RSpec.shared_examples 'expected from class method for a file' do
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

RSpec.shared_examples 'expected from class method for a url' do
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

RSpec.shared_examples 'expected from class method for raw xml' do
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

RSpec.shared_examples 'a valid MediaInfo::Tracks types generation' do

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

# MediaInfo::Tracks.*? shared examples

shared_examples 'for a valid collection of file path of videos' do
  it "return true to track_types.any?" do
    videos.each do |k, video_path|
      expect(MediaInfo.from(video_path).track_types.any?).to be true
      expect(MediaInfo.from(video_path).general?).to be true
      expect(MediaInfo.from(video_path).video?).to be true
      expect(MediaInfo.from(video_path).audio?).to be true
    end
  end
end

shared_examples 'for a valid collection of file path of images' do
  it "return true to track_types.any?" do
    images.each do |k, image_path|
      expect(MediaInfo.from(image_path).track_types.any?).to be true
      expect(MediaInfo.from(image_path).image?).to be true
      expect(MediaInfo.from(image_path).image.count).to eq(1)
    end
  end
end
