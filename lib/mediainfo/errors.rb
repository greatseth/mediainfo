module MediaInfo

  # General
  class EnvironmentError < StandardError; end
  class ExecutionError < StandardError; end
  class IncompatibleVersionError < StandardError; end
  class UnknownVersionError < StandardError; end
  class RemoteUrlError < StandardError; end

  class BadInputError < ArgumentError
    def initialize(msg=nil)
      msg ||= "Input must be: \n" \
        " - A video or xml file location: '~/videos/test_video.mov' or '~/videos/test_video.xml' \n" \
        " - A valid URL: 'http://www.site.com/videofile.mov' \n" \
        " - MediaInfo XML \n"
      super(msg)
    end
  end

  # Stream
  class InvalidTrackType < StandardError; end
  class InvalidTrackAttributeValue < StandardError; end

  class SingleStreamAPIError < RuntimeError; end
  class NoStreamsForProxyError < NoMethodError; end
end
