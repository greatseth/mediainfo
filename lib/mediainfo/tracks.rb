require 'time'
module MediaInfo
  class Tracks

    # Needed so that .image?, when there is no Image track, doesn't throw NoMethodError
    def method_missing( name, *args )
      nil # We use nil here instead of false as nil should be understood by the client/requester as false. We might not want to specifically return false for other missing methods
    end

    attr_reader :xml, :track_types

    def initialize(input = nil)
      if input && input.include?('<?xml')
        @xml = input
        @track_types = []
        # Populate Streams
        case MediaInfo.xml_parser
        when 'nokogiri'
          converted_xml = ::Nokogiri::XML(self.xml)
          converted_xml.css('//track').each { |track| # Have to use .css here due to iphone6 MediaInfo structure
            track_elements = Attributes.new(track.children.select{ |n| n.is_a? ::Nokogiri::XML::Element }.map{ |parameter|
              if parameter.text.include?("\n") # if it has children (extra in iphone6+_video.mov.xml)
                [parameter.name, parameter.children.select { |n| n.is_a? ::Nokogiri::XML::Element }.map{ |parameter| [parameter.name, parameter.text]}]
              else
                [parameter.name, parameter.text]
              end
            })
            track_type = sanitize_track_type(@track_types,track.attributes.map{ |k,v| { :name => v.name, :value => v.value } },track.children.css('ID').map{ |el| el.text })
            @track_types << track_type
            MediaInfo.set_singleton_method(self,track_type,track_elements)
          }
        else # DEFAULT REXML
          converted_xml = ::REXML::Document.new(self.xml)
          converted_xml.elements.each('//track') { |track|
            track_elements = Attributes.new(track.children.select { |n| n.is_a? ::REXML::Element }.map{ |parameter|
              if parameter.text.include?("\n") # if it has children (extra in iphone6+_video.mov.xml)
                [parameter.name, parameter.children.select { |n| n.is_a? ::REXML::Element }.map{ |parameter| [parameter.name, parameter.text]}]
              else
                [parameter.name, parameter.text]
              end
            })
            track_type = sanitize_track_type(@track_types,track.attributes.map{ |attr| { :name => attr[0], :value => attr[1] } },track.elements.detect{|el| el.name == 'id' }.to_a)
            @track_types << track_type
            MediaInfo.set_singleton_method(self,track_type,track_elements)
          }
        end

        # Add {type}?
        @track_types.each{ |track_type|
          define_singleton_method("#{track_type}?"){ # Can't use set_singleton_method due to ?
            self.track_types.any?(__method__.to_s.gsub('?',''))
          }
        }
        # Add {type}.count singleton_method
        @track_types.each{ |track_type|
          MediaInfo.set_singleton_method(self.instance_variable_get("@#{track_type}"),'count',@track_types.grep(/#{track_type}/).count)
        }

      else
        raise ArgumentError, 'Input must be raw XML.'
      end
    end # end Initialize

    class Attributes

      # Needed so that sanitize_elements doesn't throw NoMethodError
      def method_missing( name, *args )
        nil # We use nil here instead of false as nil should be understood by the client/requester as false. We might not want to specifically return false for other missing methods
      end

      def initialize(params)
        params.each{ |param|
          if param[1].is_a?(Array)
            MediaInfo.set_singleton_method(self,param[0],Extra.new(param[1]))
          else
            MediaInfo.set_singleton_method(self,param[0],MediaInfo::Tracks::Attributes.sanitize_parameter(param))
          end
        }
      end

      class Extra
        def initialize(params)
          params.each{ |param| MediaInfo.set_singleton_method(self,param[0],MediaInfo::Tracks::Attributes.sanitize_parameter(param)) }
        end
      end

      def self.sanitize_parameter(param)
        name = param[0]
        value = param[1]
        case
        when value.match(/(?!\.)\D+/).nil? then value.to_f # Convert String with integer in it to Integer
          # Duration
        when value =~ /\d+\s?h/   then value.to_i * 60 * 60 * 1000
        when value =~ /\d+\s?min/ then value.to_i * 60 * 1000
        when value =~ /\d+\s?mn/  then value.to_i * 60 * 1000
        when value =~ /\d+\s?s/   then value.to_i * 1000
        when value =~ /\d+\s?ms/  then value.to_i
          # Dates
        when name.downcase.include?('date') then Time.parse(value)
        else
          value
        end
      end

    end


    # Used for handling duplicate track types with differing streamid, etc
    # Takes an array of attributes and returns the track_name
    ## Parameters must meet the following structure:
    # TRACK_TYPES: ['video','video2','text'] or [] if nothing created yet
    # TRACK_ATTRIBUTES: [{:name=>"type", :value=>"Text" }] or [] if not found
    # TRACK_ID: ["1"] or [] if not found
    def sanitize_track_type(track_types,track_attributes,track_id)
      raise("Unable to sanitize a track type due to missing 'type' attribute in on of the elements: \n #{track_attributes}") if (type_attr_value = track_attributes.detect{ |attr| attr[:name] == 'type' }[:value]).nil?
      if (streamid = track_attributes.detect{ |attr| attr[:name] == 'streamid' || attr[:name] == 'typeorder' }).nil? # No StreamId, however, ensuring that if the streamid is there we use it ## We must still manually specify the id attr until https://sourceforge.net/p/mediainfo/discussion/297610/thread/f17a0cf5/ is answered
        ## Even if no streamid we need to check for duplicate track names and append an integer. ONLY WORKS IF DUPLICATE TRACKS ARE CONSECUTIVE
        if track_types.include?(type_attr_value.downcase)
          if !track_id.nil? && !track_id.empty? && track_id.first.to_s.to_i > 1 ## If the track has an ID child, and it's an integer above 1 (if it's a string, to_i returns 0) (if to_i returns > 1 so we can match id convention of video vs video1; see code below this section), use that
            type = "#{type_attr_value}#{track_id.first}"
          else
            type = "#{type_attr_value}#{track_types.grep(/#{type_attr_value.downcase}/).count + 1}"
          end
        else
          type = type_attr_value
        end
      else
        # For anything with a streamid of 1, ignore it. This is due to the logic of non-streamid duplicates not appending an integer for the first occurrence. We want to be consistent.
        ## We use _ to separate the streamid so we can do easier matching for non-streamid duplicates
        type = streamid[:value] == '1' ? type_attr_value : "#{type_attr_value}#{streamid[:value]}"
      end
      return type.downcase
    end

  end
end