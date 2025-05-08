module GetblockioApi
  # Aptos v1 API 资源类
  class AptosV1 < AptosBase
    API_VERSION = 'v1'.freeze  # Aptos API 版本号

    # 获取账户资源
    # @param address [String] 账户地址
    # @param ledger_version [Integer] 账本版本 (可选)
    # @return [Array] 资源列表
    def get_account_resources(address, ledger_version = nil)
      path = build_api_path("accounts/#{address}/resources")
      query = {}
      query[:ledger_version] = ledger_version if ledger_version
      rest_get(path, query)
    end

    # 获取账户
    # @param address [String] 账户地址
    # @param ledger_version [Integer] 账本版本 (可选)
    # @return [Hash] 账户信息
    def get_account(address, ledger_version = nil)
      path = build_api_path("accounts/#{address}")
      query = {}
      query[:ledger_version] = ledger_version if ledger_version
      rest_get(path, query)
    end

    # 获取交易
    # @param txn_hash [String] 交易哈希
    # @return [Hash] 交易信息
    def get_transaction(txn_hash)
      path = build_api_path("transactions/by_hash/#{txn_hash}")
      rest_get(path)
    end

    # 获取账户交易
    # @param address [String] 账户地址
    # @param limit [Integer] 限制数量 (默认: 25)
    # @param start [Integer] 起始序号 (可选)
    # @return [Array] 交易列表
    def get_account_transactions(address, limit = 25, start = nil)
      path = build_api_path("accounts/#{address}/transactions")
      query = { limit: limit }
      query[:start] = start if start
      rest_get(path, query)
    end

    # 获取区块
    # @param height [Integer] 区块高度
    # @param with_transactions [Boolean] 是否包含交易 (默认: false)
    # @return [Hash] 区块信息
    def get_block_by_height(height, with_transactions = false)
      path = build_api_path("blocks/by_height/#{height}")
      query = { with_transactions: with_transactions }
      rest_get(path, query)
    end

    # 获取账户模块
    # @param address [String] 账户地址
    # @param ledger_version [Integer] 账本版本 (可选)
    # @return [Array] 模块列表
    def get_account_modules(address, ledger_version = nil)
      path = build_api_path("accounts/#{address}/modules")
      query = {}
      query[:ledger_version] = ledger_version if ledger_version
      rest_get(path, query)
    end

    # 获取账户事件
    # @param address [String] 账户地址
    # @param event_handle [String] 事件句柄
    # @param field_name [String] 字段名
    # @param limit [Integer] 限制数量 (默认: 25)
    # @param start [Integer] 起始序号 (可选)
    # @return [Array] 事件列表
    def get_account_events(address, event_handle, field_name, limit = 25, start = nil)
      path = build_api_path("accounts/#{address}/events/#{event_handle}/#{field_name}")
      query = { limit: limit }
      query[:start] = start if start
      rest_get(path, query)
    end
    
    # 获取 Aptos 信息
    # @return [Hash] Aptos 节点信息
    def get_info
      path = build_api_path("info")
      rest_get(path)
    end
  end
end
