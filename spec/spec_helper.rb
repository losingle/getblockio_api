require 'getblockio_api'
require 'webmock/rspec'

# 禁用所有真实的网络连接，确保测试不会发出真实的 API 请求
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  # 启用 RSpec 的 expect 语法
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # 启用模拟对象
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # 共享上下文和示例
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # 随机化测试顺序
  config.order = :random
  Kernel.srand config.seed
end

# 辅助方法
def fixture_path
  File.expand_path('../fixtures', __FILE__)
end

def fixture(file)
  File.read(File.join(fixture_path, file))
end

# 创建测试目录（如果不存在）
FileUtils.mkdir_p(fixture_path) unless File.exist?(fixture_path)
