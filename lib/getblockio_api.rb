require_relative 'getblockio_api/version'
require_relative 'getblockio_api/errors'
require_relative 'getblockio_api/client'
require_relative 'getblockio_api/resource'

# Load all blockchain resource classes
require_relative 'getblockio_api/resources/ethereum'
require_relative 'getblockio_api/resources/solana'
require_relative 'getblockio_api/resources/aptos'
require_relative 'getblockio_api/resources/bitcoin'

module GetblockioApi
  # Create a new client
  # @param api_key [String] API key
  # @param api_type [String] API type (json_rpc, websocket, rest)
  # @param base_uri [String] API base URI
  # @param options [Hash] Other options
  # @return [GetblockioApi::Client] Client instance
  def self.new(api_key:, api_type: Client::API_TYPE_JSON_RPC, base_uri: nil, options: {})
    Client.new(
      api_key: api_key,
      api_type: api_type,
      base_uri: base_uri,
      options: options
    )
  end
  
  # Create an Ethereum client
  # @param client [GetblockioApi::Client] Client instance
  # @return [GetblockioApi::Ethereum] Ethereum resource
  def self.ethereum(client)
    Ethereum.new(client)
  end
  
  # Create a Bitcoin client
  # @param client [GetblockioApi::Client] Client instance
  # @return [GetblockioApi::Bitcoin] Bitcoin resource
  def self.bitcoin(client)
    Bitcoin.new(client)
  end
  
  # Create a Solana client
  # @param client [GetblockioApi::Client] Client instance
  # @return [GetblockioApi::Solana] Solana resource
  def self.solana(client)
    Solana.new(client)
  end
  
  # Create an Aptos client
  # @param client [GetblockioApi::Client] Client instance
  # @param version [String] API version (default: v1)
  # @return [GetblockioApi::AptosBase] Aptos resource
  def self.aptos(client, version = Aptos::DEFAULT_VERSION)
    Aptos.new(client, version)
  end
end
