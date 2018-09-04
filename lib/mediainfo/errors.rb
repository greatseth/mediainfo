module MediaInfo
  # General
  class Error < StandardError; end
  class EnvironmentError < Error; end
  class ExecutionError < Error; end
  class IncompatibleVersionError < Error; end
  class UnknownVersionError < Error; end
  class RemoteUrlError < Error; end
  # Stream
  class SingleStreamAPIError < RuntimeError; end
  class NoStreamsForProxyError < NoMethodError; end
  class InvalidTrackType < Error; end
  class InvalidTrackAttributeValue < Error; end
end
