# Load Aptos related resource classes
require_relative 'aptos/base'
require_relative 'aptos/v1/aptos_v1'

module GetblockioApi
  # Aptos resource factory class, used to create different versions of Aptos API implementations
  class Aptos
    # Default API version
    DEFAULT_VERSION = 'v1'.freeze
    
    # Get Aptos API implementation for the specified version
    # @param client [GetblockioApi::Client] API client instance
    # @param version [String] API version (default: v1)
    # @return [GetblockioApi::AptosBase] Aptos API implementation
    def self.new(client, version = DEFAULT_VERSION)
      case version.to_s.downcase
      when 'v1'
        AptosV1.new(client)
      else
        raise ArgumentError, "Unsupported Aptos API version: #{version}"
      end
    end
  end
end
