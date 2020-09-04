require 'forwardable'
require 'net/http'
require 'mediainfo/errors'
require 'mediainfo/tracks'
require 'mediainfo/string'
require 'open3'

module MediaInfo

  def self.which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each { |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable?(exe) && !File.directory?(exe)
      }
    end
    return nil
  end

  # Allow user to set custom mediainfo_path with ENV['MEDIAINFO_PATH']
  def self.location
    if ENV['MEDIAINFO_PATH'].nil?
      mediainfo_location = which('mediainfo')
    else
      mediainfo_location = ENV['MEDIAINFO_PATH']
      raise EnvironmentError, "MediaInfo path you provided cannot be found. Please check your mediainfo installation location..." unless ::File.exist? mediainfo_location
    end
    raise EnvironmentError, "MediaInfo binary cannot be found. Are you sure mediainfo is installed?" if mediainfo_location.nil? || mediainfo_location.empty?
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

  def self.from(input)
    return from_uri(input) if input.is_a?(URI)
    return from_string(input) if input.is_a?(String)
    raise BadInputError
  end

  def self.from_string(input)
    return from_xml(input) if input.include?('<?xml')
    return from_link(input) if input.include?('://') && input =~ URI::regexp
    return from_local_file(input) if input.match(/[^\\]*\.\w+$/)
    raise BadInputError
  end

  def self.from_xml(input)
    MediaInfo::Tracks.new(input)
  end

  def self.from_local_file(input)
    absolute_path = File.expand_path(input) # turns relative to absolute path

    raise ArgumentError, 'You must include a file location.' if absolute_path.nil?
    raise ArgumentError, "need a path to a video file, #{absolute_path} does not exist" unless File.exist?(absolute_path)

    return from_xml(File.open(absolute_path).read) if absolute_path.match(/[^\\]*\.(xml)$/)
    MediaInfo::Tracks.new(MediaInfo.run(absolute_path.shell_escape_double_quotes))
  end

  def self.from_link(input)
    from_uri(URI(input))
  end

  def self.run(input = nil)
    raise ArgumentError, 'Your input cannot be blank.' if input.nil?
    command = "#{location} \"#{input}\" --Output=XML"
    raw_response, errors, status = Open3.capture3(command)
    unless status.exitstatus == 0
      raise ExecutionError, "Execution of '#{command}' failed: \n #{errors.red}"
    end
    return raw_response
  end

  def self.from_uri(input)
    if input.host.include?('amazonaws.com')
      MediaInfo::Tracks.new(MediaInfo.run(input.to_s)) # Removed URI.escape due to Error parsing the X-Amz-Credential parameter; the Credential is mal-formed; expecting "&lt;YOUR-AKID&gt;/YYYYMMDD/REGION/SERVICE/aws4_request"
    else
      http = Net::HTTP.new(input.host, input.port) # Check if input is valid
      request = Net::HTTP::Head.new(input.request_uri) # Only grab the Headers to be sure we don't try and download the whole file; Doesn't work with presigned_urls in aws/s3
      http.use_ssl = true if input.is_a? URI::HTTPS # For https support
      http_request = http.request(request)
      raise RemoteUrlError, "HTTP call to #{input} is not working : #{http_request.value}" unless http_request.is_a?(Net::HTTPOK)
      MediaInfo::Tracks.new(MediaInfo.run(URI.escape(input.to_s)))
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
