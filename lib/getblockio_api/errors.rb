module GetblockioApi
  class Error < StandardError; end
  class ApiError < Error
    attr_reader :code, :message, :details
    def initialize(code, message, details = nil)
      @code = code
      @message = message
      @details = details
      super("API Error #{code}: #{message} #{details ? "(#{details})" : ''}")
    end
  end
  class NetworkError < Error; end
  class WebSocketError < Error; end
  class SubscriptionError < Error; end
  class AuthenticationError < Error; end
  class MethodNotAllowedError < ApiError
     def initialize(details = nil)
        super(405, "Method not allowed", details)
     end
  end
end
