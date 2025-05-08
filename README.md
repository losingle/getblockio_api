# GetBlock.io API Ruby Client

A Ruby client library for interacting with GetBlock.io blockchain services, designed with an AWS SDK-style architecture.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'getblockio_api'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install getblockio_api
```

## Usage

### Initializing the Client

```ruby
require 'getblockio_api'

# Create client instance
client = GetblockioApi.new(
  http_api_key: 'your_http_api_key',
  wss_api_key: 'your_wss_api_key',
  options: {
    logger: Logger.new(STDOUT),
    timeout: 30
  }
)

# Or create client with specific API type
client = GetblockioApi::Client.new(
  api_key: 'your_api_key',
  api_type: GetblockioApi::Client::API_TYPE_JSON_RPC, # or API_TYPE_WEBSOCKET, API_TYPE_REST
  options: {
    debug: true
  }
)
```

### Using Ethereum API

```ruby
# Get Ethereum resource
eth = GetblockioApi.ethereum(client)

# Get current block number
block_number = eth.block_number
puts "Current block number: #{block_number}"

# Get account balance
balance = eth.get_balance('0x742d35Cc6634C0532925a3b844Bc454e4438f44e')
puts "Balance: #{balance}"

# Get block information
block = eth.get_block('latest')
puts "Latest block: #{block}"

# Get transaction information
tx = eth.get_transaction('0x5c504ed432cb51138bcf09aa5e8a410dd4a1e204ef84bfed1be16dfba1b22060')
puts "Transaction: #{tx}"

# Subscribe to new block headers
subscription_id = eth.subscribe_new_heads do |block_header|
  puts "New block: #{block_header['number']}"
end

# Unsubscribe
eth.unsubscribe(subscription_id)
```

### Using Solana API

```ruby
# Get Solana resource
sol = GetblockioApi.solana(client)

# Get account information
account_info = sol.get_account_info('4fYNw3dojWmQ4dXtSGE9epjRGy9pFSx62YypT7avPYvA')
puts "Account info: #{account_info}"

# Get balance
balance = sol.get_balance('4fYNw3dojWmQ4dXtSGE9epjRGy9pFSx62YypT7avPYvA')
puts "Balance: #{balance}"

# Get block
block = sol.get_block(100)
puts "Block: #{block}"

# Subscribe to account changes
subscription_id = sol.subscribe_account('4fYNw3dojWmQ4dXtSGE9epjRGy9pFSx62YypT7avPYvA') do |account_info|
  puts "Account updated: #{account_info}"
end

# Unsubscribe
sol.unsubscribe(subscription_id)
```

### Using Aptos API

```ruby
# Get Aptos resource
apt = GetblockioApi.aptos(client)

# Get account
account = apt.get_account('0x1')
puts "Account: #{account}"

# Get account resources
resources = apt.get_account_resources('0x1')
puts "Resources: #{resources}"

# Get block
block = apt.get_block_by_height(100)
puts "Block: #{block}"

# Get node info
info = apt.get_info
puts "Node info: #{info}"
```

### Using Bitcoin API

```ruby
# Get Bitcoin resource
btc = GetblockioApi.bitcoin(client)

# Get blockchain info
info = btc.get_blockchain_info
puts "Blockchain info: #{info}"

# Get block hash
block_hash = btc.get_block_hash(680000)
puts "Block hash: #{block_hash}"

# Get block
block = btc.get_block(block_hash)
puts "Block: #{block}"

# Get block count
count = btc.get_block_count
puts "Block count: #{count}"

# Estimate fee
fee = btc.estimate_smart_fee(6)
puts "Estimated fee: #{fee}"
```

## Error Handling

```ruby
begin
  eth = GetblockioApi.ethereum(client)
  result = eth.get_balance('invalid_address')
rescue GetblockioApi::ApiError => e
  puts "API Error: #{e.code} - #{e.message}"
rescue GetblockioApi::NetworkError => e
  puts "Network Error: #{e.message}"
rescue GetblockioApi::WebSocketError => e
  puts "WebSocket Error: #{e.message}"
end
```

## API Coverage

Please note that this library does not currently implement all available GetBlock.io APIs. The implementation focuses on the most commonly used methods for each blockchain. Additional methods will be added in future updates.

## Contributing

Contributions are welcome! If you'd like to add support for additional API methods, improve documentation, or fix bugs, please feel free to submit a pull request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This gem is available as open source under the terms of the MIT License. See the LICENSE file for details.
