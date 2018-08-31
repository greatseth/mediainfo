require 'forwardable'
require 'net/http'
require 'mediainfo/errors'
require 'mediainfo/tracks'
require 'mediainfo/string'

module MediaInfo

  # Allow user to set custom mediainfo_path with ENV['MEDIAINFO_PATH']
  def self.location
    ENV['MEDIAINFO_PATH'].nil? ? mediainfo_location = '/usr/local/bin/mediainfo' : mediainfo_location = ENV['MEDIAINFO_PATH']
    raise EnvironmentError, "#{mediainfo_location} cannot be found. Are you sure mediainfo is installed?" unless ::File.exist? mediainfo_location
    return mediainfo_location
  end

  # Allow collection of MediaInfo version details
  def self.version
    version ||= `#{location} --Version`[/v([\d.]+)/, 1]
    # Ensure MediaInfo isn't buggy and returns something
    raise UnknownVersionError, 'Unable to determine mediainfo version. ' + "We tried: #{location} --Version." +
          'Set MediaInfo.path = \'/full/path/of/mediainfo\' if it is not in your PATH.' unless version
    # Ensure you're not using an old version of MediaInfo
    if version < '0.7.25'
      raise IncompatibleVersionError, "Your version of mediainfo, #{version}, " +
          'is not compatible with this gem. >= 0.7.25 required.'
    else
      @version = version
    end

  end

  def self.xml_parser
    ENV['MEDIAINFO_XML_PARSER'].nil? || ENV['MEDIAINFO_XML_PARSER'].to_s.strip.empty? ? xml_parser = 'rexml/document' : xml_parser = ENV['MEDIAINFO_XML_PARSER']
    begin
      require xml_parser
    rescue Gem::LoadError => ex
      raise Gem::LoadError, "Your specified XML parser, #{xml_parser.inspect}, could not be loaded: #{ex.message}"
    end
    return xml_parser
  end


  def self.run(input = nil)
    raise ArgumentError, 'Your input cannot be blank.' if input.nil?
    command = "#{location} #{input} --Output=XML 2>&1"
    raw_response = `#{command}`
    unless $? == 0
      raise ExecutionError, "Execution of '#{command}' failed. #{raw_response.inspect}"
    end
    return raw_response
  end

  def self.from(input)
    input_guideline_message = 'Bad Input' + "\n" + "Input must be: \n" +
        "A video or xml file location. Example: '~/videos/test_video.mov' or '~/videos/test_video.xml' \n" +
        "A valid URL. Example: 'http://www.site.com/videofile.mov' \n" +
        "Or MediaInfo XML \n"
    if input # User must specify file
      if input.include?('<?xml') # Must be first, else we could parse input (raw xml) with a URL in it and think it's a URL
        return MediaInfo::Tracks.new(input)
      elsif input.downcase.include?('http') || input.downcase.include?('www') # Handle Url Parsing
        @uri = URI(input)
        # Check if URL is valid
        http = ::Net::HTTP.new(@uri.host,@uri.port)
        request = Net::HTTP::Head.new(@uri.request_uri) # Only grab the Headers to be sure we don't try and download the whole file
        response = http.request(request)
        case response
        when Net::HTTPOK
          @escaped_input = URI.escape(@uri.to_s)
        else
          raise RemoteUrlError, "HTTP call to #{input} is not working!"
        end
      elsif input.include?('.xml')
        return MediaInfo::Tracks.new(::File.open(input).read)
      elsif !input.match(/[^\\]*\.\w+$/).nil? # A local file
        @file = ::File.expand_path input # turns ~/path/to/file into /home/user/path/to/file
        raise ArgumentError, 'You must include a file location.' if @file.nil?
        raise ArgumentError, "need a path to a video file, #{@file} does not exist" unless ::File.exist? @file
        @file_path = ::File.dirname  @file
        @filename = ::File.basename @file
        @escaped_input = @file.shell_escape_double_quotes
        # Set variable for returned XML
      else
        raise ArgumentError, input_guideline_message
      end
      return MediaInfo::Tracks.new(MediaInfo.run(@escaped_input))
    else
      raise ArgumentError, input_guideline_message
    end
  end


  def self.set_singleton_method(object,name,parameters)
    # Handle parameters with invalid characters (instance_variable_set throws error)
    name.gsub!('.','_') if name.include?('.') ## period in name
    name.downcase!
    # Create singleton_method
    object.instance_variable_set("@#{name}",parameters)
    object.define_singleton_method name do
      object.instance_variable_get "@#{name}"
    end
  end

end # end Module
