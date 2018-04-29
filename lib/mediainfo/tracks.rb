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
            attributes = Attributes.new(track.children.select{ |n| n.is_a? ::Nokogiri::XML::Element }.map{ |parameter| [parameter.name, parameter.text] })
            track_type = sanitize_track_type(@track_types,track.attributes.map{ |k,v| { :name => v.name, :value => v.value } })
            @track_types << track_type
            MediaInfo.set_singleton_method(self,track_type,attributes)
          }
        else # DEFAULT REXML
          converted_xml = ::REXML::Document.new(self.xml)
          converted_xml.elements.each('//track') { |track|
            track_elements = Attributes.new(track.children.select { |n| n.is_a? ::REXML::Element }.map{ |parameter| [parameter.name, parameter.text] })
            track_type = sanitize_track_type(@track_types,track.attributes.map{ |attr| { :name => attr[0], :value => attr[1] } })
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

    # Used for handling duplicate track types with differing streamid, etc
    # Takes an array of attributes and returns the track_name
    def sanitize_track_type(track_types,track_attributes)
      raise("Unable to sanitize a track type due to missing 'type' attribute in on of the elements: \n #{track_attributes}") if (type_attr_value = track_attributes.detect{ |attr| attr[:name] == 'type' }[:value]).nil?
      ## Unfortunately the only place we must still manually specify the id attr until https://sourceforge.net/p/mediainfo/discussion/297610/thread/f17a0cf5/ is answered
      if (streamid = track_attributes.detect{ |attr| attr[:name] == 'streamid' || attr[:name] == 'typeorder' }).nil? # No StreamId, however, ensuring that if the streamid is there we use it
        ## Even if no streamid we need to check for duplicate track names and append an integer. ONLY WORKS IF DUPLICATE TRACKS CONSECUTIVE
        if track_types.include?(type_attr_value.downcase)
          type = "#{type_attr_value}#{track_types.grep(/#{type_attr_value.downcase}/).count + 1}"
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

    class Attributes
      # TODO Make sure to get sub-xml nodes like iphone6+_video's extra under General
      def initialize(params)
        params.each{ |param|
          # TODO Sanitize/Standardize certain param_name, like bitrate. For example:
          ## bitrate may be "bit_rate" in the xml and video.bitrate will raise
          ## bitrate may return as 57.5 Kbps and not bytes
          ## Duration might
          MediaInfo.set_singleton_method(self,param[0],param[1])
        }
      end
    end

  end


end