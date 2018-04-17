module MediaInfo

  class Parameters
    def initialize(params)
      params.each{ |param|
        param_name = param[0].downcase
        param_value = param[1]
        instance_variable_set("@#{param_name}",param_value)
        define_singleton_method param_name do
          instance_variable_get "@#{param_name}"
        end
      }
    end
  end

end
