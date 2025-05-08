require_relative 'getblockio_api/version'
require_relative 'getblockio_api/errors'
require_relative 'getblockio_api/client'
require_relative 'getblockio_api/resource'

# 加载所有区块链资源类
require_relative 'getblockio_api/resources/ethereum'
require_relative 'getblockio_api/resources/solana'
require_relative 'getblockio_api/resources/aptos'
require_relative 'getblockio_api/resources/bitcoin'

module GetblockioApi
  # 创建一个新的客户端
  # @param api_key [String] API 密钥
  # @param api_type [String] API 类型（json_rpc, websocket, rest）
  # @param base_uri [String] API 基础 URI
  # @param options [Hash] 其他选项
  # @return [GetblockioApi::Client] 客户端实例
  def self.new(api_key:, api_type: Client::API_TYPE_JSON_RPC, base_uri: nil, options: {})
    Client.new(
      api_key: api_key,
      api_type: api_type,
      base_uri: base_uri,
      options: options
    )
  end
  
  # 创建一个以太坊客户端
  # @param client [GetblockioApi::Client] 客户端实例
  # @return [GetblockioApi::Ethereum] 以太坊资源
  def self.ethereum(client)
    Ethereum.new(client)
  end
  
  # 创建一个比特币客户端
  # @param client [GetblockioApi::Client] 客户端实例
  # @return [GetblockioApi::Bitcoin] 比特币资源
  def self.bitcoin(client)
    Bitcoin.new(client)
  end
  
  # 创建一个索拉纳客户端
  # @param client [GetblockioApi::Client] 客户端实例
  # @return [GetblockioApi::Solana] 索拉纳资源
  def self.solana(client)
    Solana.new(client)
  end
  
  # 创建一个 Aptos 客户端
  # @param client [GetblockioApi::Client] 客户端实例
  # @param version [String] API 版本 (默认: v1)
  # @return [GetblockioApi::AptosBase] Aptos 资源
  def self.aptos(client, version = Aptos::DEFAULT_VERSION)
    Aptos.new(client, version)
  end
end
