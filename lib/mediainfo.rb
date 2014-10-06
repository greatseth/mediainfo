require "forwardable"
require "mediainfo/string"
require "mediainfo/attr_readers"

=begin
# Mediainfo

Mediainfo is a class wrapping [the mediainfo CLI](http://mediainfo.sourceforge.net).

## Installation
    
    $ gem install mediainfo
    
## Usage
    
    info = Mediainfo.new "/path/to/file"
    
That will issue the system call to `mediainfo` and parse the output. 
You can specify an alternate path if necessary:
    
    Mediainfo.path = "/opt/local/bin/mediainfo"
    
Once you have an info object, you can start inspecting streams and general metadata.
    
    info.streams.count # 2
    info.audio?        # true
    info.video?        # true
    info.image?        # false
    
When inspecting specific types of streams, you have a couple general API options. The 
first approach assumes one stream of a given type, a common scenario in many video files, 
for example.
    
    info.video.count    # 1
    info.audio.count    # 1
    info.video.duration # 120 (seconds)
    
Sometimes you'll have more than one stream of a given type. Quicktime files can often 
contain artifacts like this from somebody editing a more 'normal' file.
    
    info = Mediainfo.new "funky.mov"
    
    info.video?            # true
    info.video.count       # 2
    info.video.duration    # raises SingleStreamAPIError !
    info.video[0].duration # 120
    info.video[1].duration # 10
    
For some more usage examples, please see the very reasonable test suite accompanying the source code 
for this library. It contains a bunch of relevant usage examples. More docs in the future.. contributions 
*very* welcome!

Moving on, REXML is used as the XML parser by default. If you'd like, you can 
configure Mediainfo to use Hpricot or Nokogiri instead using one of 
the following approaches:

  * define the `MEDIAINFO_XML_PARSER` environment variable to be the 
    name of the parser as you'd pass to a :gem or :require call. 
    
    e.g. `export MEDIAINFO_XML_PARSER=nokogiri`
    
  * assign to Mediainfo.xml_parser after you've loaded the gem, 
    following the same naming conventions mentioned previously.
    
    e.g. `Mediainfo.xml_parser = "hpricot"`
    

Once you've got an instance setup, you can call numerous methods to get 
a variety of information about a file. Some attributes may be present 
for some files where others are not, but any supported attribute 
should at least return `nil`.

For a list of all possible attributes supported:
  
    Mediainfo.supported_attributes
  
## Requirements

This requires at least the following version of the Mediainfo CLI:
  
    MediaInfo Command line,
    MediaInfoLib - v0.7.25
  
Previous versions of this gem(<= 0.5.1) worked against v0.7.11, which did not 
generate XML output, and is no longer supported.
=end
class Mediainfo
  extend Forwardable
  extend AttrReaders
  
  class Error < StandardError; end
  class ExecutionError < Error; end
  class IncompatibleVersionError < Error; end
  class UnknownVersionError < Error; end
  
  def self.delegate(method_name, stream_type = nil)
    if stream_type == :general
      def_delegator :"@#{stream_type}_stream", method_name
    else
      def_delegator :"@#{stream_type}_stream", method_name, "#{stream_type}_#{method_name}"
    end
  end
  
  def self.version
    @version ||= `#{version_command}`[/v([\d.]+)/, 1]
  end
  
  def self.version_command
    "#{path} --Version"
  end
  
  # AttrReaders depends on this.
  def self.supported_attributes; @supported_attributes ||= []; end
  
  SECTIONS             = [:general, :video, :audio, :image, :menu, :text, :other]
  NON_GENERAL_SECTIONS = SECTIONS - [:general]
  
  attr_reader :streams
  
  # Size of source file as reported by File.size.
  # Returns nil if you haven't yet fired off the system command.
  def size; File.size(@full_filename) if @full_filename; end
  
  class StreamProxy
    def initialize(mediainfo, stream_type)
      unless Mediainfo::SECTIONS.include? stream_type
        raise ArgumentError, "invalid stream_type: #{stream_type.inspect}"
      end
      
      @stream_type = stream_type
      @mediainfo   = mediainfo
      @streams     = @mediainfo.streams.select { |x| x.send("#{stream_type}?") }
    end
    
    def [](id); @streams[id];  end
    def count;  @streams.size; end
    attr_reader :streams
    attr_reader :stream_type
    
    class SingleStreamAPIError < RuntimeError; end
    class NoStreamsForProxyError < NoMethodError; end
    
    def method_missing(m, *a, &b)
      if streams.size > 1
        raise SingleStreamAPIError, "You cannot use the single stream, convenience API on a multi-stream file."
      else
        if relevant_stream = streams.detect { |s| s.respond_to?(m) }
          relevant_stream.send(m, *a, &b)
        else
          raise NoStreamsForProxyError, "there are no :#{stream_type} streams to send :#{m} to"
        end
      end
    end
  end
  
  class Stream
    class InvalidStreamType < Mediainfo::Error; end
    
    def self.inherited(stream_type)
      stream_type.extend(AttrReaders)
      
      def stream_type.method_added(method_name)
        if stream_type = name[/[^:]+$/][/^(#{SECTIONS.map { |x| x.to_s.capitalize } * '|'})/]
          stream_type.downcase! 
          stream_type = stream_type.to_sym
        else
          raise "could not determine stream type, please report bug!"
        end
        
        Mediainfo.delegate(method_name, stream_type)
      end
    end
    
    def self.create(stream_type)
      raise ArgumentError, "need a stream_type, received #{stream_type.inspect}" if stream_type.nil?
      
      stream_class_name = "#{stream_type}Stream"
      
      if Mediainfo.const_defined?(stream_class_name)
        Mediainfo.const_get(stream_class_name).new(stream_type)
      else
        raise InvalidStreamType, "bad stream type: #{stream_type.inspect}"
      end
    end
    
    def initialize(stream_type)
      raise ArgumentError, "need a stream_type, received #{stream_type.inspect}" if stream_type.nil?
      
      @stream_type = stream_type.downcase.to_sym
      
      # TODO @parsed_response is not the best name anymore, but I'm leaving it 
      # alone to focus on refactoring the interface to the streams 
      # before I refactor the attribute reader implementations.
      @parsed_response = { @stream_type => {} }
    end
    
    attr_reader :parsed_response
    
    def [](k); @parsed_response[@stream_type][k]; end
    def []=(k,v); @parsed_response[@stream_type][k] = v; end
    
    Mediainfo::SECTIONS.each { |t| define_method("#{t}?") { t == @stream_type } }
  end
  
  class GeneralStream < Stream
    mediainfo_attr_reader :codec_id, "Codec ID"
    
    mediainfo_duration_reader :duration
    
    mediainfo_attr_reader :format
    mediainfo_attr_reader :format_profile
    mediainfo_attr_reader :format_info
    mediainfo_attr_reader :overall_bit_rate
    mediainfo_attr_reader :writing_application
    mediainfo_attr_reader :writing_library
    
    mediainfo_date_reader :mastered_date
    mediainfo_date_reader :tagged_date
    mediainfo_date_reader :encoded_date
  end
  
  class VideoStream < Stream
    mediainfo_attr_reader :stream_id, "ID"
    
    mediainfo_duration_reader :duration
    
    mediainfo_attr_reader :stream_size
    mediainfo_attr_reader :bit_rate
    mediainfo_attr_reader :nominal_bit_rate
    
    mediainfo_attr_reader :bit_rate_mode
    def cbr?; video? and "Constant" == bit_rate_mode; end
    def vbr?; video? and not cbr?; end

    mediainfo_attr_reader :scan_order
    mediainfo_attr_reader :scan_type
    def interlaced?;  video? and "Interlaced" == scan_type; end
    def progressive?; video? and not interlaced? end

    mediainfo_int_reader :resolution

    mediainfo_attr_reader :colorimetry
    alias_method :colorspace, :colorimetry

    mediainfo_attr_reader :format
    mediainfo_attr_reader :format_info
    mediainfo_attr_reader :format_profile
    mediainfo_attr_reader :format_version
    mediainfo_attr_reader :format_settings_cabac, "Format settings, CABAC"
    mediainfo_attr_reader :format_settings_reframes, "Format settings, ReFrames"
    mediainfo_attr_reader :format_settings_matrix, "Format settings, Matrix"
    # Format settings, BVOP            : Yes
    # Format settings, QPel            : No
    # Format settings, GMC             : No warppoints
    # mediainfo_attr_reader :format_settings_qpel, "Format settings, QPel"
    mediainfo_attr_reader :color_primaries
    mediainfo_attr_reader :transfer_characteristics
    mediainfo_attr_reader :matrix_coefficients

    mediainfo_attr_reader :codec_id, "Codec ID"
    mediainfo_attr_reader :codec_info, "Codec ID/Info"
    alias_method :codec_id_info, :codec_info

    mediainfo_attr_reader :frame_rate
    def fps; frame_rate[/[\d.]+/].to_f if frame_rate; end
    alias_method :framerate, :fps

    mediainfo_attr_reader :minimum_frame_rate
    def min_fps; minimum_frame_rate[/[\d.]+/].to_f if video?; end
    alias_method :min_framerate, :min_fps

    mediainfo_attr_reader :maximum_frame_rate
    def max_fps; maximum_frame_rate[/[\d.]+/].to_f if video?; end
    alias_method :max_framerate, :max_fps

    mediainfo_attr_reader :frame_rate_mode

    mediainfo_attr_reader :display_aspect_ratio
    # alias_method :display_aspect_ratio, :display_aspect_ratio

    mediainfo_attr_reader :bits_pixel_frame, "Bits/(Pixel*Frame)"

    mediainfo_int_reader :width
    mediainfo_int_reader :height

    def frame_size; "#{width}x#{height}" if width or height; end

    mediainfo_date_reader :encoded_date
    mediainfo_date_reader :tagged_date
    
    mediainfo_attr_reader :standard
  end
  
  class AudioStream < Stream
    mediainfo_attr_reader :stream_id, "ID"
    
    mediainfo_duration_reader :duration
    
    mediainfo_attr_reader :sampling_rate
    def sample_rate
      return unless rate = sampling_rate_before_type_cast
      number = rate.gsub(/[^\d.]+/, "").to_f
      number = case rate
      when /KHz/ then number * 1000
      when /Hz/  then number
      else
        raise "unhandled sample rate! please report bug!"
      end
      number.to_i
    end
    alias_method :sampling_rate, :sample_rate

    mediainfo_attr_reader :stream_size
    mediainfo_attr_reader :bit_rate
    mediainfo_attr_reader :bit_rate_mode
    mediainfo_attr_reader :interleave_duration, "Interleave, duration"

    mediainfo_int_reader :resolution
    alias_method :sample_bit_depth, :resolution

    mediainfo_attr_reader :format
    mediainfo_attr_reader :format_profile
    mediainfo_attr_reader :format_version
    mediainfo_attr_reader :format_info, "Format/Info"
    mediainfo_attr_reader :format_settings_sbr, "Format settings, SBR"
    mediainfo_attr_reader :format_settings_endianness, "Format settings, Endianness"
    mediainfo_attr_reader :format_settings_sign, "Format settings, Sign"
    mediainfo_attr_reader :codec_id, "Codec ID"
    mediainfo_attr_reader :codec_info, "Codec ID/Info"
    mediainfo_attr_reader :codec_id_hint
    mediainfo_attr_reader :channel_positions

    mediainfo_int_reader :channels, "Channel(s)"
    def stereo?; 2 == channels; end
    def mono?;   1 == channels; end

    mediainfo_date_reader :encoded_date
    mediainfo_date_reader :tagged_date
  end
  
  class ImageStream < Stream
    mediainfo_attr_reader :resolution
    mediainfo_attr_reader :format
    
    mediainfo_int_reader :width
    mediainfo_int_reader :height
   
    def frame_size; "#{width}x#{height}" if width or height; end
  end

  class TextStream < Stream
    mediainfo_attr_reader :stream_id, "ID"
    mediainfo_attr_reader :format
    mediainfo_attr_reader :codec_id, "Codec ID"
    mediainfo_attr_reader :codec_info, "Codec ID/Info"
  end
  
  class MenuStream < Stream
    mediainfo_attr_reader :stream_id, "ID"
    mediainfo_date_reader :encoded_date
    mediainfo_date_reader :tagged_date
    mediainfo_int_reader :delay
  end

  class OtherStream < Stream
  end

  Mediainfo::SECTIONS.each do |stream_type|
    class_eval %{
      def #{stream_type}; @#{stream_type}_proxy ||= StreamProxy.new(self, :#{stream_type}); end
      def #{stream_type}?; streams.any? { |x| x.#{stream_type}? }; end
    }, __FILE__, __LINE__
  end
  
  ###
  
  attr_reader :raw_response, :full_filename, :filename, :path, :escaped_full_filename
  
  ###
  
  def initialize(full_filename = nil)
    unless mediainfo_version
      raise UnknownVersionError,
        "Unable to determine mediainfo version. " +
        "We tried: #{self.class.version_command} " +
        "Are you sure mediainfo is installed at #{self.class.path.inspect}? " + 
        "Set Mediainfo.path = /where/is/mediainfo if it is not in your PATH."
    end
    
    if mediainfo_version < "0.7.25"
      raise IncompatibleVersionError,
        "Your version of mediainfo, #{mediainfo_version}, " +
        "is not compatible with this gem. >= 0.7.25 required."
    end
    
    @streams = []
    
    if full_filename
      @full_filename = File.expand_path full_filename
      @path          = File.dirname  @full_filename
      @filename      = File.basename @full_filename
      
      raise ArgumentError, "need a path to a video file, got nil" unless @full_filename
      raise ArgumentError, "need a path to a video file, #{@full_filename} does not exist" unless File.exist? @full_filename
      
      @escaped_full_filename = @full_filename.shell_escape_double_quotes
      
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

  def self.default_mediainfo_path!
    self.path = default_mediainfo_path
  end

  def self.default_mediainfo_path
    local_bin_path = File.expand_path File.join('../../', 'ext', 'mediainfo'), __FILE__

    File.exists?(local_bin_path) ? local_bin_path : "mediainfo"
  end

  default_mediainfo_path! unless path
  
  def mediainfo_version; self.class.version; end
  
  attr_reader :last_command
  
  def inspect
    super.sub(/@raw_response=".+?", @/, %{@raw_response="...", @})
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
    
    case xml_parser
    when "nokogiri"
      Nokogiri::XML(@raw_response).xpath("//track").each { |t|
        s = Stream.create(t['type'])
        t.xpath("*").each do |c|
          s[key_for(c)] = c.content.strip
        end
        @streams << s
      }
    when "hpricot"
      Hpricot::XML(@raw_response).search("track").each { |t|
        s = Stream.create(t['type'])
        t.children.select { |n| n.is_a? Hpricot::Elem }.each do |c|
          s[key_for(c)] = c.inner_html.strip
        end
        @streams << s
      }
    else
      REXML::Document.new(@raw_response).elements.each("/Mediainfo/File/track") { |t|
        s = Stream.create(t.attributes['type'])
        t.children.select { |n| n.is_a? REXML::Element }.each do |c|
          s[key_for(c)] = c.text.strip
        end
        @streams << s
      }
    end
    
    SECTIONS.each do |section|
      default_target_stream = if send("#{section}?")
        send(section).streams.first
      else
        Mediainfo.const_get("#{section.to_s.capitalize}Stream").new(section.to_s.capitalize)
      end
      instance_variable_set "@#{section}_stream", default_target_stream
    end
  end
  
  def key_for(attribute_node)
    attribute_node.name.downcase.gsub(/_+/, "_").gsub(/_s(\W|$)/, "s").strip
  end
end
