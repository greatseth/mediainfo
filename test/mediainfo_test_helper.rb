class ActiveSupport::TestCase
  def self.mediainfo_test_size
    test "size" do
      File.expects(:size).with(@info.full_filename)
      @info.size
    end
  end
  
  def assert_no_streams_error(&block)
    assert_raises(Mediainfo::StreamProxy::NoStreamsForProxyError, &block)
  end
  
  def self.mediainfo_test_not_an_image
    test "image?" do
      assert !@info.image?
    end
    
    test "image format" do
      assert_raises(Mediainfo::StreamProxy::NoStreamsForProxyError) { @info.image.format }
    end
  
    test "image width" do
      assert_raises(Mediainfo::StreamProxy::NoStreamsForProxyError) { @info.image.width }
    end
  
    test "image height" do
      assert_raises(Mediainfo::StreamProxy::NoStreamsForProxyError) { @info.image.height }
    end
  
    test "image resolution" do
      assert_raises(Mediainfo::StreamProxy::NoStreamsForProxyError) { @info.image.resolution }
    end
  end
  
  def self.test_stream_type_queries(options = {})
    (options[:expect] + [:general]).each do |stream_type_to_expect|
      test "#{stream_type_to_expect}?" do
        assert @info.send("#{stream_type_to_expect}?"),
          "should have responded with TRUE to :#{stream_type_to_expect}?"
      end
    end
    
    (Mediainfo::SECTIONS - options[:expect] - [:general]).each do |unexpected_stream_type|
      test "#{unexpected_stream_type}?" do
        assert !@info.send("#{unexpected_stream_type}?"),
          "should have responded with FALSE to :#{unexpected_stream_type}?"
      end
    end
  end
  
  def mediainfo_mock(name)
    Mediainfo.any_instance.stubs(:mediainfo!).returns(mediainfo_fixture(name))
    Mediainfo.new "/dev/null"
  end
  
  def mediainfo_fixture(name)
    File.read(File.join(File.dirname(__FILE__), "fixtures", "#{name}.xml"))
  end
end
