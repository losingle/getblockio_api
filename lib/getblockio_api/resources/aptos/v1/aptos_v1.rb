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

    # Get transaction by hash
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

    # Get events by event handle
    # @param address [String] Account address
    # @param event_handle [String] Struct tag of the event handle defined by the module that emitted the event
    # @param field_name [String] Field name of the event stream on the event handle. e.g. 'withdraw_events' or 'deposit_events'
    # @param limit [Integer] Limit count (default: 25)
    # @param start [Integer] Start sequence number (optional)
    # @return [Array] Event list
    def get_account_events(address, event_handle, field_name, limit = 25, start = nil)
      path = build_api_path("accounts/#{address}/events/#{event_handle}/#{field_name}")
      query = { limit: limit }
      query[:start] = start if start
      rest_get(path, query)
    end
    
    # Get Aptos information (Ledger Info)
    # @return [Hash] Aptos node information
    def get_info
      path = build_api_path("info")
      rest_get(path)
    end

    # Get account events by creation number
    # @param address [String] Account address
    # @param creation_number [String] Creation number of the event stream on the account
    # @param limit [Integer] Limit count (default: 25)
    # @param start [Integer] Start sequence number (optional)
    # @return [Array] Event list
    def get_account_events_by_creation_number(address, creation_number, limit = 25, start = nil)
      path = build_api_path("accounts/#{address}/events/#{creation_number}")
      query = { limit: limit }
      query[:start] = start if start
      rest_get(path, query)
    end

    # Get account module ABI
    # @param address [String] Account address
    # @param module_name [String] Name of the module to retrieve.
    # @param ledger_version [Integer] Ledger version (optional)
    # @return [Hash] Module ABI and bytecode
    def get_account_module(address, module_name, ledger_version = nil)
      path = build_api_path("accounts/#{address}/module/#{module_name}")
      query = {}
      query[:ledger_version] = ledger_version if ledger_version
      rest_get(path, query)
    end

    # Get account resource by type
    # @param address [String] Account address
    # @param resource_type [String] Type of the resource to retrieve. e.g. '0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>'
    # @param ledger_version [Integer] Ledger version (optional)
    # @return [Hash] Resource information
    def get_account_resource(address, resource_type, ledger_version = nil)
      # resource_type might need URL encoding if it contains special characters.
      encoded_resource_type = CGI.escape(resource_type)
      path = build_api_path("accounts/#{address}/resource/#{encoded_resource_type}")
      query = {}
      query[:ledger_version] = ledger_version if ledger_version
      rest_get(path, query)
    end

    # Get block by version
    # @param version [Integer] Block version
    # @param with_transactions [Boolean] Whether to include transactions (default: false)
    # @return [Hash] Block information
    def get_block_by_version(version, with_transactions = false)
      path = build_api_path("blocks/by_version/#{version}")
      query = { with_transactions: with_transactions }
      rest_get(path, query)
    end

    # Estimate gas price
    # @return [Hash] Gas estimation
    def estimate_gas_price
      path = build_api_path('estimate_gas_price')
      rest_get(path)
    end

    # Submit transaction (JSON)
    # @param payload [Hash] Transaction payload as a JSON object
    # @return [Hash] Transaction submission result
    def submit_transaction(payload)
      path = build_api_path('transactions')
      @client.rest_post_raw(path, payload.to_json, {})
    end

    # Submit transaction (BCS)
    # This method requires the client to support sending a raw body with a specific Content-Type.
    # @param bcs_payload [String] BCS encoded transaction (hex-string starting with 0x)
    # @return [Hash] Transaction submission result
    def submit_bcs_transaction(bcs_payload)
      path = build_api_path('transactions')
      headers = { 'Content-Type' => 'application/x.aptos.signed_transaction+bcs' }
      @client.rest_post_raw(path, bcs_payload, headers)
    end

    # Submit batch transactions (JSON)
    # @param payloads [Array<Hash>] Array of transaction payloads as JSON objects
    # @return [Array<Hash>] Batch transaction submission results
    def submit_batch_transactions(payloads)
      path = build_api_path('transactions/batch')
      @client.rest_post_raw(path, payloads.to_json, {})
    end

    # Get transaction by version
    # @param version [Integer] Transaction version
    # @return [Hash] Transaction information
    def get_transaction_by_version(version)
      path = build_api_path("transactions/by_version/#{version}")
      rest_get(path)
    end
  end
end
