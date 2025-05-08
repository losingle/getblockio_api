require 'spec_helper'

RSpec.describe GetblockioApi::Ethereum do
  let(:api_key) { 'test_api_key' }
  let(:client) { GetblockioApi::Client.new(api_key: api_key, api_type: GetblockioApi::Client::API_TYPE_JSON_RPC) }
  let(:ethereum) { GetblockioApi::Ethereum.new(client) }

  describe '#block_number' do
    let(:response_body) { fixture('ethereum_block_number.json') }
    let(:expected_result) { '0xf91ba1' }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'eth_blockNumber',
            params: [],
            id: 'getblock.io'
          }.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(
          status: 200,
          body: response_body,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'returns the current block number' do
      expect(ethereum.block_number).to eq(expected_result)
    end
  end

  describe '#get_balance' do
    let(:address) { '0x742d35Cc6634C0532925a3b844Bc454e4438f44e' }
    let(:block) { 'latest' }
    let(:response_body) do
      {
        jsonrpc: '2.0',
        id: 'getblock.io',
        result: '0x1a055690d9db80000'
      }.to_json
    end
    let(:expected_result) { '0x1a055690d9db80000' }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'eth_getBalance',
            params: [address, block],
            id: 'getblock.io'
          }.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(
          status: 200,
          body: response_body,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'returns the balance of the given address' do
      expect(ethereum.get_balance(address, block)).to eq(expected_result)
    end
  end

  describe '#net_version' do
    let(:response_body) do
      {
        jsonrpc: '2.0',
        id: 'getblock.io',
        result: '1'
      }.to_json
    end
    let(:expected_result) { '1' }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'net_version',
            params: [],
            id: 'getblock.io'
          }.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(
          status: 200,
          body: response_body,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'returns the current network ID' do
      expect(ethereum.net_version).to eq(expected_result)
    end
  end
end
