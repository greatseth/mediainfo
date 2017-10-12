require "time"
require "mediainfo/string"

class  Mediainfo
module AttrReaders
  def mediainfo_attr_reader(method_name, mediainfo_key = nil)
    # NOTE explicit self necessary here until we rename local var 'name'
    stream_class_type = name[/::([^:]+)Stream$/, 1]
    
    before_type_cast_method_name = "#{method_name}_before_type_cast"
    mediainfo_key = mediainfo_key.gsub(/\W+/, "_").downcase if mediainfo_key
    
    if m = stream_class_type.match(/^#{Regexp.union *Mediainfo::NON_GENERAL_SECTIONS.map { |x| x.to_s.capitalize }}$/)
      k1 = stream_class_type.downcase.to_sym
    else
      k1 = :general
    end
    
    define_method before_type_cast_method_name do
      if v = instance_variable_get("@#{before_type_cast_method_name}")
        v
      else
        k2 = mediainfo_key ? mediainfo_key : method_name.to_s
        v = @parsed_response[k1][k2]
        
        instance_variable_set "@#{before_type_cast_method_name}", v
        instance_variable_get "@#{before_type_cast_method_name}"
      end
    end
    
    define_method method_name do
      if v = instance_variable_get("@#{method_name}")
        v
      else
        v = send(before_type_cast_method_name)
        v = yield v if v and block_given?
        
        instance_variable_set "@#{method_name}", v
        instance_variable_get "@#{method_name}"
      end
    end
    
    supported_attribute = method_name
    supported_attribute = "#{stream_class_type.downcase}_#{method_name}".to_sym unless k1 == :general
    Mediainfo.supported_attributes << supported_attribute
  end
  
  def mediainfo_duration_reader(*a)
    mediainfo_attr_reader *a do |v|
      t = 0
      v.scan(/\d+\s?\w+/).each do |tf|
        case tf
          # MPEG2 Entertainment (HBO, Showtime, and Starz) and ADs have durations with spaces between \d and ms/s/mn/h. New Regex below will account for that, maintaining original support.
          when /\d+\s?h/  then t += tf.to_i * 60 * 60 * 1000
          when /\d+\s?min/ then t += tf.to_i * 60 * 1000 # Never seen mn used, so we need to support both
          when /\d+\s?mn/ then t += tf.to_i * 60 * 1000
          when /\d+\s?s/  then t += tf.to_i * 1000
          when /\d+\s?ms/ then t += tf.to_i
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
end
end
