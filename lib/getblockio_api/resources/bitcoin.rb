module GetblockioApi
  # Bitcoin Resource class
  class Bitcoin < Resource
    BLOCKCHAIN_PATH = ''.freeze

    # Get blockchain information
    # @return [Hash] Blockchain information
    def get_blockchain_info
      json_rpc('getblockchaininfo')
    end

    # Get block hash
    # @param height [Integer] Block height
    # @return [String] Block hash
    def get_block_hash(height)
      json_rpc('getblockhash', [height])
    end

    # Get block
    # @param hash [String] Block hash
    # @param verbosity [Integer] Verbosity level (0-2)
    # @return [Hash|String] Block information or hexadecimal string
    def get_block(hash, verbosity = 1)
      json_rpc('getblock', [hash, verbosity])
    end
    
    # Get block count
    # @return [Integer] Block count
    def get_block_count
      json_rpc('getblockcount')
    end

    # Get raw transaction
    # @param txid [String] Transaction ID
    # @param verbose [Boolean] Whether to include detailed information (default: false)
    # @return [String|Hash] Transaction hex string or detailed information
    def get_raw_transaction(txid, verbose = false)
      json_rpc('getrawtransaction', [txid, verbose])
    end

    # Decode raw transaction
    # @param hex [String] Transaction hex string
    # @return [Hash] Decoded transaction information
    def decode_raw_transaction(hex)
      json_rpc('decoderawtransaction', [hex])
    end

    # Get transaction output
    # @param txid [String] Transaction ID
    # @param n [Integer] Output index
    # @param include_mempool [Boolean] Whether to include mempool (default: true)
    # @return [Hash] Transaction output information
    def get_tx_out(txid, n, include_mempool = true)
      json_rpc('gettxout', [txid, n, include_mempool])
    end

    # Get mempool information
    # @return [Hash] Mempool information
    def get_mempool_info
      json_rpc('getmempoolinfo')
    end

    # Get raw mempool contents
    # @param verbose [Boolean] Whether to include detailed information (default: false)
    # @return [Hash|Array] Mempool contents
    def get_raw_mempool(verbose = false)
      json_rpc('getrawmempool', [verbose])
    end

    # Send raw transaction
    # @param hex [String] Transaction hex string
    # @return [String] Transaction ID
    def send_raw_transaction(hex)
      json_rpc('sendrawtransaction', [hex])
    end

    # Estimate smart fee
    # @param conf_target [Integer] Target number of confirmations
    # @param estimate_mode [String] Estimation mode (default: "CONSERVATIVE")
    # @return [Float] Fee rate per kB (BTC)
    def estimate_smart_fee(conf_target, estimate_mode = 'CONSERVATIVE')
      json_rpc('estimatesmartfee', [conf_target, estimate_mode])
    end
    
    # Abort rescan
    # @return [Boolean] Whether the abort was successful
    def abort_rescan
      json_rpc('abortrescan')
    end
  end
end
