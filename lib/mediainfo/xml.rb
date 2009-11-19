gem     "nokogiri"
require "nokogiri"

# gem     "hpricot"
# require "hpricot"

class Mediainfo
  class XML < self
    def generate_command
      super << " --Output=XML"
    end
    
    def parse!
      @parsed_response = {}
      
      xml = Nokogiri::XML(@raw_response)
      # xml = Hpricot::XML(@raw_response)
      xml.search("track").each { |t|
        section = t['type']
        
        bucket = if SECTIONS.include? section
          @parsed_response[section] ||= {}
          @parsed_response[section]
        else
          @parsed_response
        end
        
        t.children.each { |c| bucket[c] = c.value }
      }
    end
    
  end
end
