require 'mediainfo/parameters'

module MediaInfo
  class Tracks

    attr_reader :xml

    def initialize(input = nil)
      if input && input.include?('<?xml')
        @xml = input

        # Populate Tracks
        case MediaInfo.xml_parser
        when 'nokogiri'
          ::Nokogiri::XML(self.xml).xpath('//track').each { |t|
            track = MediaInfo::Track.new(t['type'])
            t.children.select { |n| n.is_a? ::Hpricot::Elem }.each{ |c| track.parameters[c.name] = c.content.strip }
            @tracks << track
          }
        when 'hpricot'
          ::Hpricot::XML(self.xml).search('track').each { |t|
            track = MediaInfo::Track.new(t['type'])
            t.children.select { |n| n.is_a? ::Hpricot::Elem }.each{ |c| track.parameters[c.name] = c.inner_html.strip }
            @tracks << track
          }
        else # DEFAULT REXML
          ::REXML::Document.new(self.xml).elements.each('/MediaInfo/media/track') { |t|
            parameters = MediaInfo::Parameters.new(t.children.select { |n| n.is_a? ::REXML::Element }.map{ |parameter| [parameter.name,parameter.text] })
            track_type = t.attributes['type'].downcase
            instance_variable_set("@#{track_type}",parameters)
            define_singleton_method track_type do
              instance_variable_get "@#{track_type}"
            end
          }
        end
      else
        raise ArgumentError, 'Input must be raw XML.'
      end
    end # end Initialize

  end
end