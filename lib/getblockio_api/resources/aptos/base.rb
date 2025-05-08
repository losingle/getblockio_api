module GetblockioApi
  # Aptos 资源基类
  class AptosBase < Resource
    BLOCKCHAIN_PATH = ''.freeze  # Aptos 使用空路径，通过 API 密钥区分
    
    # 获取当前使用的 API 版本
    # @return [String] API 版本
    def api_version
      self.class::API_VERSION
    end
    
    # 构建 API 路径
    # @param path [String] 路径
    # @return [String] 完整的 API 路径
    def build_api_path(path)
      "#{api_version}/#{path}"
    end
  end
end
