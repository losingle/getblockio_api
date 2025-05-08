module GetblockioApi
  # 索拉纳 Resource 类
  class Solana < Resource
    BLOCKCHAIN_PATH = ''.freeze  # 索拉纳使用空路径，通过 API 密钥区分

    # 获取账户信息
    # @param pubkey [String] 公钥
    # @param commitment [String] 确认级别 (默认: "finalized")
    # @return [Hash] 账户信息
    def get_account_info(pubkey, commitment = 'finalized')
      json_rpc('getAccountInfo', [pubkey, { commitment: commitment }])
    end

    # 获取余额
    # @param pubkey [String] 公钥
    # @param commitment [String] 确认级别 (默认: "finalized")
    # @return [Integer] 余额（lamports）
    def get_balance(pubkey, commitment = 'finalized')
      json_rpc('getBalance', [pubkey, { commitment: commitment }])
    end

    # 获取区块
    # @param slot [Integer] 槽号
    # @param commitment [String] 确认级别 (默认: "finalized")
    # @return [Hash] 区块信息
    def get_block(slot, commitment = 'finalized')
      json_rpc('getBlock', [slot, { commitment: commitment }])
    end

    # 获取区块高度
    # @param commitment [String] 确认级别 (默认: "finalized")
    # @return [Integer] 区块高度
    def get_block_height(commitment = 'finalized')
      json_rpc('getBlockHeight', [{ commitment: commitment }])
    end

    # 获取最新区块哈希
    # @param commitment [String] 确认级别 (默认: "finalized")
    # @return [String] 区块哈希
    def get_latest_blockhash(commitment = 'finalized')
      json_rpc('getLatestBlockhash', [{ commitment: commitment }])
    end

    # 获取交易
    # @param signature [String] 交易签名
    # @param commitment [String] 确认级别 (默认: "finalized")
    # @return [Hash] 交易信息
    def get_transaction(signature, commitment = 'finalized')
      json_rpc('getTransaction', [signature, { commitment: commitment }])
    end

    # 发送交易
    # @param encoded_tx [String] Base64 编码的交易
    # @param commitment [String] 确认级别 (默认: "finalized")
    # @return [String] 交易签名
    def send_transaction(encoded_tx, commitment = 'finalized')
      json_rpc('sendTransaction', [encoded_tx, { encoding: 'base64', commitment: commitment }])
    end

    # 获取代币账户余额
    # @param pubkey [String] 代币账户公钥
    # @param commitment [String] 确认级别 (默认: "finalized")
    # @return [Hash] 代币余额信息
    def get_token_account_balance(pubkey, commitment = 'finalized')
      json_rpc('getTokenAccountBalance', [pubkey, { commitment: commitment }])
    end

    # 获取程序账户
    # @param program_id [String] 程序 ID
    # @param commitment [String] 确认级别 (默认: "finalized")
    # @return [Array] 程序账户列表
    def get_program_accounts(program_id, commitment = 'finalized')
      json_rpc('getProgramAccounts', [program_id, { commitment: commitment }])
    end

    # 订阅账户变更
    # @param pubkey [String] 公钥
    # @param commitment [String] 确认级别 (默认: "finalized")
    # @param callback [Block] 处理订阅消息的回调
    # @return [String] 订阅 ID
    def subscribe_account(pubkey, commitment = 'finalized', &callback)
      subscribe('accountSubscribe', [pubkey, { commitment: commitment }], &callback)
    end

    # 订阅程序
    # @param program_id [String] 程序 ID
    # @param commitment [String] 确认级别 (默认: "finalized")
    # @param callback [Block] 处理订阅消息的回调
    # @return [String] 订阅 ID
    def subscribe_program(program_id, commitment = 'finalized', &callback)
      subscribe('programSubscribe', [program_id, { commitment: commitment }], &callback)
    end
  end
end
