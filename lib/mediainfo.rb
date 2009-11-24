require "mediainfo/string"
require "mediainfo/attr_readers"

# Mediainfo is a class encapsulating the ability to run `mediainfo` 
# on a file and expose the information it produces in a straightforward 
# manner.
# 
# Basic usage:
#   
#   info = Mediainfo.new "/path/to/file"
#   
# That will issue the system call to `mediainfo` and parse the output. 
# From there, you can call numerous methods to get a variety of information 
# about a file. Some attributes may be present for some files where others 
# are not.
# 
# You may also initialize a Mediainfo instance using raw CLI output 
# you have saved for some reason.
# 
#   info = Mediainfo.new
#   info.raw_response = cli_output
# 
# Setting the raw_response triggers the system call, and from that point on 
# the object should behave the same as if you'd initialized it with the path 
# to a file.
# 
# For a list of all possible attributes supported:
#   
#   Mediainfo.supported_attributes
#   
# In addition to the stock arguments provided by parsing `mediainfo` output, 
# some convenience methods and added behavior is added.
class Mediainfo
  extend AttrReaders
  
  SECTIONS = %w( audio video image ) # and General
  
  ### GENERAL
  
  mediainfo_attr_reader :codec_id, "Codec ID"
  
  mediainfo_duration_reader :duration
  
  mediainfo_attr_reader :format
  mediainfo_attr_reader :format_profile
  mediainfo_attr_reader :format_info
  mediainfo_attr_reader :overall_bit_rate
  mediainfo_attr_reader :writing_application
  mediainfo_attr_reader :writing_library
  
  def size; File.size(@full_filename); end
  
  mediainfo_date_reader :mastered_date
  mediainfo_date_reader :tagged_date
  mediainfo_date_reader :encoded_date
  
  ### VIDEO
  
  mediainfo_section_query :video
  
  mediainfo_attr_reader :video_stream_id, "ID"
  
  mediainfo_duration_reader :video_duration
  
  mediainfo_attr_reader :video_stream_size
  mediainfo_attr_reader :video_bit_rate
  mediainfo_attr_reader :video_nominal_bit_rate
  
  mediainfo_attr_reader :video_bit_rate_mode
  def cbr?; video? and "Constant" == video_bit_rate_mode; end
  def vbr?; video? and not cbr?; end
  
  mediainfo_attr_reader :video_scan_order
  mediainfo_attr_reader :video_scan_type
  def interlaced?;  video? and "Interlaced" == video_scan_type; end
  def progressive?; video? and not interlaced? end
  
  mediainfo_int_reader :video_resolution
  
  mediainfo_attr_reader :video_colorimetry
  alias_method :video_colorspace, :video_colorimetry
  
  mediainfo_attr_reader :video_format
  mediainfo_attr_reader :video_format_profile
  mediainfo_attr_reader :video_format_version
  mediainfo_attr_reader :video_format_settings_cabac, "Format settings, CABAC"
  mediainfo_attr_reader :video_format_settings_reframes, "Format settings, ReFrames"
  mediainfo_attr_reader :video_format_settings_matrix, "Format settings, Matrix"
  # Format settings, BVOP            : Yes
  # Format settings, QPel            : No
  # Format settings, GMC             : No warppoints
  # mediainfo_attr_reader :video_format_settings_qpel, "Format settings, QPel"
  mediainfo_attr_reader :video_color_primaries
  mediainfo_attr_reader :video_transfer_characteristics
  mediainfo_attr_reader :video_matrix_coefficients
  
  mediainfo_attr_reader :video_codec_id, "Codec ID"
  mediainfo_attr_reader :video_codec_info, "Codec ID/Info"
  
  mediainfo_attr_reader :video_frame_rate
  def fps; video_frame_rate[/[\d.]+/].to_f if video?; end
  alias_method :framerate, :fps
  
  mediainfo_attr_reader :video_minimum_frame_rate
  def min_fps; video_minimum_frame_rate[/[\d.]+/].to_f if video?; end
  alias_method :min_framerate, :min_fps
  
  mediainfo_attr_reader :video_maximum_frame_rate
  def max_fps; video_maximum_frame_rate[/[\d.]+/].to_f if video?; end
  alias_method :max_framerate, :max_fps
  
  mediainfo_attr_reader :video_frame_rate_mode
  
  mediainfo_attr_reader :video_display_aspect_ratio
  alias_method :display_aspect_ratio, :video_display_aspect_ratio
  
  mediainfo_attr_reader :video_bits_pixel_frame, "Bits/(Pixel*Frame)"
  
  mediainfo_int_reader :video_width
  mediainfo_int_reader :video_height
  
  def resolution; "#{width}x#{height}" if video? or image?; end
  def width;  if video?; video_width;  elsif image?; image_width;  end; end
  def height; if video?; video_height; elsif image?; image_height; end; end
  
  mediainfo_date_reader :video_encoded_date
  mediainfo_date_reader :video_tagged_date
  
  ### AUDIO
  
  mediainfo_section_query :audio
  
  mediainfo_attr_reader :audio_stream_id, "ID"
  
  mediainfo_duration_reader :audio_duration
  
  mediainfo_attr_reader :audio_sampling_rate
  def audio_sample_rate
    return unless rate = audio_sampling_rate_before_type_cast
    number = rate.gsub(/[^\d.]+/, "").to_f
    number = case rate
    when /KHz/ then number * 1000
    when /Hz/  then number
    else
      raise "unhandled sample rate! please report bug!"
    end
    number.to_i
  end
  alias_method :audio_sampling_rate, :audio_sample_rate
  
  mediainfo_attr_reader :audio_stream_size
  mediainfo_attr_reader :audio_bit_rate
  mediainfo_attr_reader :audio_bit_rate_mode
  mediainfo_attr_reader :audio_interleave_duration, "Interleave, duration"
  
  mediainfo_int_reader :audio_resolution
  alias_method :audio_sample_bit_depth, :audio_resolution
  
  mediainfo_attr_reader :audio_format
  mediainfo_attr_reader :audio_format_info, "Format/Info"
  mediainfo_attr_reader :audio_format_settings_endianness, "Format settings, Endianness"
  mediainfo_attr_reader :audio_format_settings_sign, "Format settings, Sign"
  mediainfo_attr_reader :audio_codec_id, "Codec ID"
  mediainfo_attr_reader :audio_codec_info, "Codec ID/Info"
  mediainfo_attr_reader :audio_codec_id_hint
  mediainfo_attr_reader :audio_channel_positions
  
  mediainfo_int_reader :audio_channels, "Channel(s)"
  def stereo?; 2 == audio_channels; end
  def mono?;   1 == audio_channels; end
  
  mediainfo_date_reader :audio_encoded_date
  mediainfo_date_reader :audio_tagged_date
  
  ### IMAGE
  
  mediainfo_section_query :image
  mediainfo_attr_reader :image_resolution
  mediainfo_attr_reader :image_format
  
  mediainfo_int_reader :image_width
  mediainfo_int_reader :image_height
  
  ###
  
  attr_reader :raw_response, :parsed_response,
    :full_filename, :filename, :path, :escaped_full_filename
  
  ###
  
  class Error < StandardError; end
  class ExecutionError < Error; end
  class IncompatibleVersionError < Error; end
  
  def self.version
    @version ||= `#{path} --Version`[/v([\d.]+)/, 1]
  end
  
  ###
  
  def initialize(full_filename = nil)
    if mediainfo_version < "0.7.25"
      raise IncompatibleVersionError,
        "Your version of mediainfo, #{mediainfo_version}, " +
        "is not compatible with this gem. >= 0.7.25 required."
    end
    
    if full_filename
      @full_filename = File.expand_path full_filename
      @path          = File.dirname  @full_filename
      @filename      = File.basename @full_filename
      
      raise ArgumentError, "need a path to a video file, got nil" unless @full_filename
      raise ArgumentError, "need a path to a video file, #{@full_filename} does not exist" unless File.exist? @full_filename
      
      @escaped_full_filename = @full_filename.shell_escape
      
      self.raw_response = mediainfo!
    end
  end
  
  def raw_response=(response)
    raise ArgumentError, "raw response is nil" if response.nil?
    @raw_response = response
    parse!
    @raw_response
  end
  
  class << self
    attr_accessor :path
    
    def load_xml_parser!(parser = xml_parser)
      begin
        gem     parser
        require parser
      rescue Gem::LoadError => e
        raise Gem::LoadError,
          "your specified XML parser, #{parser.inspect}, could not be loaded: #{e}"
      end
    end
    
    attr_reader :xml_parser
    def xml_parser=(parser)
      load_xml_parser! parser
      @xml_parser = parser
    end
  end
  
  unless ENV["MEDIAINFO_XML_PARSER"].to_s.strip.empty?
    self.xml_parser = ENV["MEDIAINFO_XML_PARSER"]
  end
  
  def path; self.class.path; end
  def xml_parser; self.class.xml_parser; end
  
  def self.default_mediainfo_path!; self.path = "mediainfo"; end
  default_mediainfo_path! unless path
  
  def mediainfo_version
    self.class.version
  end
  
  attr_reader :last_command
  
  def inspect
    super.sub /@raw_response=".+?", @/, %{@raw_response="...", @}
  end
  
private
  def mediainfo!
    @last_command = "#{path} #{@escaped_full_filename} --Output=XML"
    run_command!
  end
  
  def run_command!
    raw_response = `#{@last_command} 2>&1`
    unless $? == 0
      raise ExecutionError,
        "Execution of `#{@last_command}` failed: #{raw_response.inspect}"
    end
    raw_response
  end
  
  def parse!
    if xml_parser
      self.class.load_xml_parser!
    else
      require "rexml/document"
    end
    
    @parsed_response = {}
    
    case xml_parser
    when "nokogiri"
      Nokogiri::XML(@raw_response).search("track").each { |t|
        bucket = bucket_for t['type']

        t.children.css("*").each do |c|
          bucket[key_for(c)] = c.content.strip
        end
      }
    when "hpricot"
      Hpricot::XML(@raw_response).search("track").each { |t|
        bucket = bucket_for t['type']

        t.children.select { |n| n.is_a? Hpricot::Elem }.each do |c|
          bucket[key_for(c)] = c.inner_html.strip
        end
      }
    else
      REXML::Document.new(@raw_response).elements.each("/Mediainfo/File/track") { |t|
        bucket = bucket_for t.attributes['type']
        
        t.children.select { |n| n.is_a? REXML::Element }.each do |c|
          bucket[key_for(c)] = c.text.strip
        end
      }
    end
  end
  
  def key_for(attribute_node)
    attribute_node.name.downcase.gsub(/_+/, "_").gsub(/_s(\W|$)/, "s").strip
  end
  
  def bucket_for(section)
    section = section.downcase if section
    
    if section == "general"
      @parsed_response
    else
      @parsed_response[section] ||= {}
      @parsed_response[section]
    end
  end
end
