module MediaInfo
  class Tracks
    attr_reader :xml
    def initialize(input = nil)
      if input && input.include?('<?xml')
        @xml = input
        # Populate Tracks
        case MediaInfo.xml_parser
        when 'nokogiri'
          ::Nokogiri::XML(self.xml).xpath('//track').each { |track|
            attributes = Attributes.new(track.children.select{ |n| n.is_a? ::Nokogiri::XML::Element }.map{ |parameter| [parameter.name, parameter.text] })
            track_type_name = sanitize_track_type(track.attributes.map{ |k,v| { :name => v.name, :value => v.value } })
            MediaInfo.set_singleton_method(self,track_type_name,attributes)
          }
        else # DEFAULT REXML
          ::REXML::Document.new(self.xml).elements.each('//track') { |track|
            track_elements = Attributes.new(track.children.select { |n| n.is_a? ::REXML::Element }.map{ |parameter| [parameter.name, parameter.text] })
            track_type = sanitize_track_type(track.attributes.map{ |attr| { :name => attr[0], :value => attr[1] } })
            MediaInfo.set_singleton_method(self,track_type,track_elements)
          }
        end
      else
        raise ArgumentError, 'Input must be raw XML.'
      end
    end # end Initialize

    # Used for handling duplicate track types with differing streamid, etc
    # Takes an array of attributes and returns the track_name
    def sanitize_track_type(track_attributes)
      raise("Unable to sanitize a track type due to missing 'type' attribute in on of the elements: \n #{track_attributes}") if (type_attr_value = track_attributes.detect{ |attr| attr[:name] == 'type' }[:value]).nil?
      if (streamid = track_attributes.detect{ |attr| attr[:name] == 'streamid' }).nil? # No StreamId
        type = type_attr_value
      else
        type = "#{type_attr_value}#{streamid[:value]}"
      end
      return type.downcase
    end

    class Attributes
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