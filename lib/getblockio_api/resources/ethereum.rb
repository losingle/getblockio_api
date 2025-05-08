module GetblockioApi
  # Ethereum Resource class
  class Ethereum < Resource
    BLOCKCHAIN_PATH = ''.freeze  # Ethereum uses an empty path, differentiated by API key

    # Get block number
    # @return [String] Current block number (hexadecimal)
    def block_number
      json_rpc('eth_blockNumber')
    end

    # Get account balance
    # @param address [String] Account address
    # @param block [String] Block number or tag (default: "latest")
    # @return [String] Balance (hexadecimal)
    def get_balance(address, block = 'latest')
      json_rpc('eth_getBalance', [address, block])
    end

    # Get block information
    # @param block_id [String|Integer] Block number or hash
    # @param full_transactions [Boolean] Whether to include full transaction information
    # @return [Hash] Block information
    def get_block(block_id, full_transactions = false)
      method = block_id.is_a?(String) && block_id.start_with?('0x') ? 
               'eth_getBlockByHash' : 'eth_getBlockByNumber'
      
      block_param = block_id.is_a?(Integer) ? "0x#{block_id.to_s(16)}" : block_id
      json_rpc(method, [block_param, full_transactions])
    end
    
    # Get network version
    # @return [String] Network ID
    def net_version
      json_rpc('net_version')
    end

    # Get transaction information
    # @param tx_hash [String] Transaction hash
    # @return [Hash] Transaction information
    def get_transaction(tx_hash)
      json_rpc('eth_getTransactionByHash', [tx_hash])
    end

    # Get transaction receipt
    # @param tx_hash [String] Transaction hash
    # @return [Hash] Transaction receipt
    def get_transaction_receipt(tx_hash)
      json_rpc('eth_getTransactionReceipt', [tx_hash])
    end

    # Call contract method (without sending a transaction)
    # @param to [String] Contract address
    # @param data [String] Encoded call data
    # @param from [String] Sender address (optional)
    # @param block [String] Block number or tag (default: "latest")
    # @return [String] Return value (hexadecimal)
    def call(to, data, from = nil, block = 'latest')
      params = { to: to, data: data }
      params[:from] = from if from
      json_rpc('eth_call', [params, block])
    end

    # Estimate gas usage for a transaction
    # @param params [Hash] Transaction parameters
    # @return [String] Gas usage (hexadecimal)
    def estimate_gas(params)
      json_rpc('eth_estimateGas', [params])
    end

    # Get gas price
    # @return [String] Gas price (hexadecimal)
    def gas_price
      json_rpc('eth_gasPrice')
    end

    # Send raw transaction
    # @param raw_tx [String] Signed raw transaction data
    # @return [String] Transaction hash
    def send_raw_transaction(raw_tx)
      json_rpc('eth_sendRawTransaction', [raw_tx])
    end

    # Get contract code
    # @param address [String] Contract address
    # @param block [String] Block number or tag (default: "latest")
    # @return [String] Contract code (hexadecimal)
    def get_code(address, block = 'latest')
      json_rpc('eth_getCode', [address, block])
    end

    # Get transaction count
    # @param address [String] Account address
    # @param block [String] Block number or tag (default: "latest")
    # @return [String] Transaction count (hexadecimal)
    def get_transaction_count(address, block = 'latest')
      json_rpc('eth_getTransactionCount', [address, block])
    end

    # Subscribe to new block headers
    # @param callback [Block] Callback for handling subscription messages
    # @return [String] Subscription ID
    def subscribe_new_heads(&callback)
      subscribe('eth_subscribe', ['newHeads'], &callback)
    end

    # Subscribe to logs
    # @param filter [Hash] Log filter
    # @param callback [Block] Callback for handling subscription messages
    # @return [String] Subscription ID
    def subscribe_logs(filter, &callback)
      subscribe('eth_subscribe', ['logs', filter], &callback)
    end
  end
end
