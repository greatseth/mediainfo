gem     "nokogiri"
require "nokogiri"

class Mediainfo
  # TODO for version 2.0, let's have Mediainfo::Base
  # inside a Mediainfo module, and then Mediainfo::XML < Mediainfo::Base
  class XML < self
    def generate_command
      super << " --Output=XML"
    end
    
    def parse!
      @parsed_response = {}
      
      xml = Nokogiri::XML(@raw_response)
      xml.search("track").each { |t|
        section = t['type']
        
        bucket = if SECTIONS.include? section
          @parsed_response[section] ||= {}
          @parsed_response[section]
        else
          @parsed_response
        end
        
        t.children.css("*").each do |c|
          key   = c.name.gsub(/_+/, " ").strip
          value = c.content.strip
          bucket[key] = value
        end
      }
    end
    
  end
end
