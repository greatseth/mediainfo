require "rubygems"
require "active_support" # TODO selective includes once they are released

class  Mediainfo
module AttrReaders
  def supported_attributes
    @supported_attributes ||= []
  end
  
  def mediainfo_attr_reader(name, mediainfo_key = nil)
    supported_attributes << name
    attr_name = "#{name}_before_type_cast"
    define_method attr_name do
      if v = instance_variable_get("@#{attr_name}")
        v
      else
        v = if md = name.to_s.match(/^(#{SECTIONS.map { |x| x.underscore } * "|"})_(.+)$/)
          k = mediainfo_key ? mediainfo_key : md[2].humanize.capitalize
          if subsection = @parsed_response[md[1].capitalize]
            subsection[k]
          end
        else
          k = mediainfo_key ? mediainfo_key : name.to_s.humanize.capitalize
          @parsed_response[k]
        end
        
        instance_variable_set "@#{attr_name}", v
        v
      end
    end
    
    define_method name do
      if v = instance_variable_get("@#{name}")
        v
      else
        v = send "#{name}_before_type_cast"
        v = yield v if v and block_given?
        
        instance_variable_set "@#{name}", v
        v
      end
    end
  end
  
  def mediainfo_duration_reader(*a)
    mediainfo_attr_reader *a do |v|
      t = 0
      v.split(/\s+/).each do |tf|
        case tf
        # XXX haven't actually seen hot they represent hours yet 
        # but hopefully this is ok.. :\
        when /\d+h/  then t += tf.to_i * 60 * 60 * 1000
        when /\d+mn/ then t += tf.to_i * 60 * 1000
        when /\d+ms/ then t += tf.to_i
        when /\d+s/  then t += tf.to_i * 1000
        else
          raise "unexpected time fragment! please report bug!"
        end
      end
      t
    end
  end
  
  def mediainfo_date_reader(*a)
    mediainfo_attr_reader(*a) { |v| Time.parse v }
  end
  
  def mediainfo_int_reader(*a)
    mediainfo_attr_reader(*a) { |v| v.gsub(/\D+/, "").to_i }
  end
  
  def mediainfo_section_query(name)
    define_method("#{name}?") { @parsed_response.key? name.to_s.capitalize }
  end
end
end
