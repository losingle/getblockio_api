module GetblockioApi
  # 比特币 Resource 类
  class Bitcoin < Resource
    BLOCKCHAIN_PATH = ''.freeze

    # 获取区块链信息
    # @return [Hash] 区块链信息
    def get_blockchain_info
      json_rpc('getblockchaininfo')
    end

    # 获取区块哈希
    # @param height [Integer] 区块高度
    # @return [String] 区块哈希
    def get_block_hash(height)
      json_rpc('getblockhash', [height])
    end

    # 获取区块
    # @param hash [String] 区块哈希
    # @param verbosity [Integer] 详细程度 (0-2)
    # @return [Hash|String] 区块信息或十六进制字符串
    def get_block(hash, verbosity = 1)
      json_rpc('getblock', [hash, verbosity])
    end
    
    # 获取区块数量
    # @return [Integer] 区块数量
    def get_block_count
      json_rpc('getblockcount')
    end

    # 获取原始交易
    # @param txid [String] 交易 ID
    # @param verbose [Boolean] 是否详细 (默认: false)
    # @return [String|Hash] 交易十六进制字符串或详细信息
    def get_raw_transaction(txid, verbose = false)
      json_rpc('getrawtransaction', [txid, verbose])
    end

    # 解码原始交易
    # @param hex [String] 交易十六进制字符串
    # @return [Hash] 解码后的交易信息
    def decode_raw_transaction(hex)
      json_rpc('decoderawtransaction', [hex])
    end

    # 获取交易输出
    # @param txid [String] 交易 ID
    # @param n [Integer] 输出索引
    # @param include_mempool [Boolean] 是否包含内存池 (默认: true)
    # @return [Hash] 交易输出信息
    def get_tx_out(txid, n, include_mempool = true)
      json_rpc('gettxout', [txid, n, include_mempool])
    end

    # 获取内存池信息
    # @return [Hash] 内存池信息
    def get_mempool_info
      json_rpc('getmempoolinfo')
    end

    # 获取内存池内容
    # @param verbose [Boolean] 是否详细 (默认: false)
    # @return [Hash|Array] 内存池内容
    def get_raw_mempool(verbose = false)
      json_rpc('getrawmempool', [verbose])
    end

    # 发送原始交易
    # @param hex [String] 交易十六进制字符串
    # @return [String] 交易 ID
    def send_raw_transaction(hex)
      json_rpc('sendrawtransaction', [hex])
    end

    # 估算手续费
    # @param conf_target [Integer] 确认目标区块数
    # @param estimate_mode [String] 估算模式 (默认: "CONSERVATIVE")
    # @return [Float] 每 kB 的费率（BTC）
    def estimate_smart_fee(conf_target, estimate_mode = 'CONSERVATIVE')
      json_rpc('estimatesmartfee', [conf_target, estimate_mode])
    end
    
    # 中止重新扫描
    # @return [Boolean] 是否成功中止
    def abort_rescan
      json_rpc('abortrescan')
    end
  end
end
