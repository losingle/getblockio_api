module GetblockioApi
  # Aptos resource base class
  class AptosBase < Resource
    BLOCKCHAIN_PATH = ''.freeze  # Aptos uses an empty path, differentiated by API key
    
    # Get the current API version
    # @return [String] API version
    def api_version
      self.class::API_VERSION
    end
    
    # Build API path
    # @param path [String] Path
    # @return [String] Complete API path
    def build_api_path(path)
      "#{api_version}/#{path}"
    end
  end
end
