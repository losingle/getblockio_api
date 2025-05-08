Gem::Specification.new do |s|
  s.name        = 'getblockio_api'
  s.version     = '0.3.0'
  s.summary     = "A Ruby client for interacting with GetBlock blockchain APIs (AWS SDK style)."
  s.description = "Provides methods to interact with Ethereum, Solana, Aptos, and Bitcoin nodes via HTTP/WSS using potentially separate API keys, inspired by AWS SDK architecture, targeting GetBlock.io services."
  s.authors     = ["Your Name"]
  s.email       = 'your.email@example.com'
  # Ensure file paths match the new directory structure
  s.files       = Dir['lib/**/*.rb'] + ['README.md']
  s.homepage    = 'https://github.com/losingle/getblockio_api'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.7.0'

  # Add dependencies
  s.add_dependency 'httparty', '~> 0.20'
  s.add_dependency 'json', '~> 2.6'
  s.add_dependency 'faye-websocket', '~> 0.11'
  s.add_dependency 'eventmachine', '~> 1.2'

  # Development dependencies (optional)
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rake', '~> 13.0'

  # Specify require_paths, if the structure under the lib directory has changed
  s.require_paths = ["lib"]
end
