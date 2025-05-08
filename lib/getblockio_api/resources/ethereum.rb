module GetblockioApi
  # 以太坊 Resource 类
  class Ethereum < Resource
    BLOCKCHAIN_PATH = ''.freeze  # 以太坊使用空路径，通过 API 密钥区分

    # 获取区块号
    # @return [String] 当前区块号（十六进制）
    def block_number
      json_rpc('eth_blockNumber')
    end

    # 获取账户余额
    # @param address [String] 账户地址
    # @param block [String] 区块号或标签 (默认: "latest")
    # @return [String] 余额（十六进制）
    def get_balance(address, block = 'latest')
      json_rpc('eth_getBalance', [address, block])
    end

    # 获取区块信息
    # @param block_id [String|Integer] 区块号或哈希
    # @param full_transactions [Boolean] 是否包含完整交易信息
    # @return [Hash] 区块信息
    def get_block(block_id, full_transactions = false)
      method = block_id.is_a?(String) && block_id.start_with?('0x') ? 
               'eth_getBlockByHash' : 'eth_getBlockByNumber'
      
      block_param = block_id.is_a?(Integer) ? "0x#{block_id.to_s(16)}" : block_id
      json_rpc(method, [block_param, full_transactions])
    end
    
    # 获取网络版本
    # @return [String] 网络 ID
    def net_version
      json_rpc('net_version')
    end

    # 获取交易信息
    # @param tx_hash [String] 交易哈希
    # @return [Hash] 交易信息
    def get_transaction(tx_hash)
      json_rpc('eth_getTransactionByHash', [tx_hash])
    end

    # 获取交易收据
    # @param tx_hash [String] 交易哈希
    # @return [Hash] 交易收据
    def get_transaction_receipt(tx_hash)
      json_rpc('eth_getTransactionReceipt', [tx_hash])
    end

    # 调用合约方法（不发送交易）
    # @param to [String] 合约地址
    # @param data [String] 编码后的调用数据
    # @param from [String] 发送方地址（可选）
    # @param block [String] 区块号或标签 (默认: "latest")
    # @return [String] 返回值（十六进制）
    def call(to, data, from = nil, block = 'latest')
      params = { to: to, data: data }
      params[:from] = from if from
      json_rpc('eth_call', [params, block])
    end

    # 估算交易 gas 用量
    # @param params [Hash] 交易参数
    # @return [String] gas 用量（十六进制）
    def estimate_gas(params)
      json_rpc('eth_estimateGas', [params])
    end

    # 获取 gas 价格
    # @return [String] gas 价格（十六进制）
    def gas_price
      json_rpc('eth_gasPrice')
    end

    # 发送原始交易
    # @param raw_tx [String] 签名后的原始交易数据
    # @return [String] 交易哈希
    def send_raw_transaction(raw_tx)
      json_rpc('eth_sendRawTransaction', [raw_tx])
    end

    # 获取代码
    # @param address [String] 合约地址
    # @param block [String] 区块号或标签 (默认: "latest")
    # @return [String] 合约代码（十六进制）
    def get_code(address, block = 'latest')
      json_rpc('eth_getCode', [address, block])
    end

    # 获取交易计数
    # @param address [String] 账户地址
    # @param block [String] 区块号或标签 (默认: "latest")
    # @return [String] 交易计数（十六进制）
    def get_transaction_count(address, block = 'latest')
      json_rpc('eth_getTransactionCount', [address, block])
    end

    # 订阅新区块头
    # @param callback [Block] 处理订阅消息的回调
    # @return [String] 订阅 ID
    def subscribe_new_heads(&callback)
      subscribe('eth_subscribe', ['newHeads'], &callback)
    end

    # 订阅日志
    # @param filter [Hash] 日志过滤器
    # @param callback [Block] 处理订阅消息的回调
    # @return [String] 订阅 ID
    def subscribe_logs(filter, &callback)
      subscribe('eth_subscribe', ['logs', filter], &callback)
    end
  end
end
