module GetblockioApi
  # Aptos v1 API Resource class
  class AptosV1 < AptosBase
    API_VERSION = 'v1'.freeze  # Aptos API version

    # Get account resources
    # @param address [String] Account address
    # @param ledger_version [Integer] Ledger version (optional)
    # @return [Array] Resource list
    def get_account_resources(address, ledger_version = nil)
      path = build_api_path("accounts/#{address}/resources")
      query = {}
      query[:ledger_version] = ledger_version if ledger_version
      rest_get(path, query)
    end

    # Get account
    # @param address [String] Account address
    # @param ledger_version [Integer] Ledger version (optional)
    # @return [Hash] Account information
    def get_account(address, ledger_version = nil)
      path = build_api_path("accounts/#{address}")
      query = {}
      query[:ledger_version] = ledger_version if ledger_version
      rest_get(path, query)
    end

    # Get transaction
    # @param txn_hash [String] Transaction hash
    # @return [Hash] Transaction information
    def get_transaction(txn_hash)
      path = build_api_path("transactions/by_hash/#{txn_hash}")
      rest_get(path)
    end

    # Get account transactions
    # @param address [String] Account address
    # @param limit [Integer] Limit count (default: 25)
    # @param start [Integer] Start sequence number (optional)
    # @return [Array] Transaction list
    def get_account_transactions(address, limit = 25, start = nil)
      path = build_api_path("accounts/#{address}/transactions")
      query = { limit: limit }
      query[:start] = start if start
      rest_get(path, query)
    end

    # Get block by height
    # @param height [Integer] Block height
    # @param with_transactions [Boolean] Whether to include transactions (default: false)
    # @return [Hash] Block information
    def get_block_by_height(height, with_transactions = false)
      path = build_api_path("blocks/by_height/#{height}")
      query = { with_transactions: with_transactions }
      rest_get(path, query)
    end

    # Get account modules
    # @param address [String] Account address
    # @param ledger_version [Integer] Ledger version (optional)
    # @return [Array] Module list
    def get_account_modules(address, ledger_version = nil)
      path = build_api_path("accounts/#{address}/modules")
      query = {}
      query[:ledger_version] = ledger_version if ledger_version
      rest_get(path, query)
    end

    # Get account events
    # @param address [String] Account address
    # @param event_handle [String] Event handle
    # @param field_name [String] Field name
    # @param limit [Integer] Limit count (default: 25)
    # @param start [Integer] Start sequence number (optional)
    # @return [Array] Event list
    def get_account_events(address, event_handle, field_name, limit = 25, start = nil)
      path = build_api_path("accounts/#{address}/events/#{event_handle}/#{field_name}")
      query = { limit: limit }
      query[:start] = start if start
      rest_get(path, query)
    end
    
    # Get Aptos information
    # @return [Hash] Aptos node information
    def get_info
      path = build_api_path("info")
      rest_get(path)
    end
  end
end
