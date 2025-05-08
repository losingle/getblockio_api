module GetblockioApi
  # Base resource class, parent class for all blockchain-specific resource classes
  class Resource
    attr_reader :client, :blockchain_path

    # API types
    API_TYPE_JSON_RPC = Client::API_TYPE_JSON_RPC
    API_TYPE_WEBSOCKET = Client::API_TYPE_WEBSOCKET
    API_TYPE_REST = Client::API_TYPE_REST

    # Initialize resource
    # @param client [GetblockioApi::Client] API client instance
    # @param blockchain_path [String] Blockchain-specific path
    def initialize(client, blockchain_path = '')
      raise ArgumentError, "Client is required" unless client.is_a?(GetblockioApi::Client)
      @client = client
      @blockchain_path = blockchain_path
    end

    # Send JSON-RPC request
    # @param method [String] Method name
    # @param params [Array, Hash] Parameters
    # @return [Hash] API response
    def json_rpc(method, params = [])
      client.json_rpc_post(blockchain_path, method, params)
    end

    # Send REST GET request
    # @param path [String] Path
    # @param query [Hash] Query parameters
    # @return [Hash, Array] API response
    def rest_get(path, query = {})
      # Build full path, handle empty blockchain_path
      full_path = if blockchain_path.empty?
                   path
                 else
                   "#{blockchain_path}/#{path}"
                 end
      client.rest_get(full_path, query)
    end

    # Subscribe to WebSocket events
    # @param method [String] Subscription method
    # @param params [Array] Subscription parameters
    # @param callback [Block] Callback for handling subscription messages
    # @return [String] Subscription ID
    def subscribe(method, params = [], &callback)
      client.subscribe(blockchain_path, method, params, &callback)
    end

    # Unsubscribe from WebSocket events
    # @param subscription_id [String] Subscription ID
    # @return [Boolean] Whether unsubscription was successful
    def unsubscribe(subscription_id)
      client.unsubscribe(subscription_id)
    end
  end

  # Load all resource classes
  require_relative 'resources/ethereum'
  require_relative 'resources/solana'
  require_relative 'resources/aptos'
  require_relative 'resources/bitcoin'







  # Module methods for creating resource instances
  class << self
    # Create Ethereum resource
    # @param client [GetblockioApi::Client] API client instance
    # @return [GetblockioApi::Ethereum] Ethereum resource instance
    def ethereum(client)
      Ethereum.new(client, Ethereum::BLOCKCHAIN_PATH)
    end

    # Create Solana resource
    # @param client [GetblockioApi::Client] API client instance
    # @return [GetblockioApi::Solana] Solana resource instance
    def solana(client)
      Solana.new(client, Solana::BLOCKCHAIN_PATH)
    end

    # Create Aptos resource
    # @param client [GetblockioApi::Client] API client instance
    # @return [GetblockioApi::Aptos] Aptos resource instance
    def aptos(client)
      Aptos.new(client, Aptos::BLOCKCHAIN_PATH)
    end

    # Create Bitcoin resource
    # @param client [GetblockioApi::Client] API client instance
    # @return [GetblockioApi::Bitcoin] Bitcoin resource instance
    def bitcoin(client)
      Bitcoin.new(client, Bitcoin::BLOCKCHAIN_PATH)
    end
  end
end
