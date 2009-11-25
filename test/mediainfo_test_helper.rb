class ActiveSupport::TestCase
  def self.mediainfo_test_size
    test "size" do
      File.expects(:size).with(@info.full_filename)
      @info.size
    end
  end
  
  def self.mediainfo_test_not_an_image
    test "image?" do
      assert !@info.image?
    end
    
    test "image format" do
      assert_nil @info.image_format
    end
  
    test "image width" do
      assert_nil @info.image_width
    end
  
    test "image height" do
      assert_nil @info.image_height
    end
  
    test "image resolution" do
      assert_nil @info.image_resolution
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
