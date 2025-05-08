# 加载 Aptos 相关资源类
require_relative 'aptos/base'
require_relative 'aptos/v1/aptos_v1'

module GetblockioApi
  # Aptos 资源工厂类，用于创建不同版本的 Aptos API 实现
  class Aptos
    # 默认 API 版本
    DEFAULT_VERSION = 'v1'.freeze
    
    # 获取指定版本的 Aptos API 实现
    # @param client [GetblockioApi::Client] API 客户端实例
    # @param version [String] API 版本 (默认: v1)
    # @return [GetblockioApi::AptosBase] Aptos API 实现
    def self.new(client, version = DEFAULT_VERSION)
      case version.to_s.downcase
      when 'v1'
        AptosV1.new(client)
      else
        raise ArgumentError, "Unsupported Aptos API version: #{version}"
      end
    end
  end
end
