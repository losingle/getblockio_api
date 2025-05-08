require 'spec_helper'

RSpec.describe GetblockioApi::Client do
  let(:api_key) { 'test_api_key' }
  let(:client) { GetblockioApi::Client.new(api_key: api_key, api_type: GetblockioApi::Client::API_TYPE_JSON_RPC) }
  let(:rest_client) { GetblockioApi::Client.new(api_key: api_key, api_type: GetblockioApi::Client::API_TYPE_REST) }
  let(:wss_client) { GetblockioApi::Client.new(api_key: api_key, api_type: GetblockioApi::Client::API_TYPE_WEBSOCKET) }

  describe '#initialize' do
    it 'raises an error if API key is not provided' do
      expect { GetblockioApi::Client.new(api_key: nil) }.to raise_error(ArgumentError)
      expect { GetblockioApi::Client.new(api_key: '') }.to raise_error(ArgumentError)
    end

    it 'raises an error if API type is invalid' do
      expect { GetblockioApi::Client.new(api_key: api_key, api_type: 'invalid_type') }.to raise_error(ArgumentError)
    end

    it 'initializes with default values' do
      expect(client.instance_variable_get(:@api_key)).to eq(api_key)
      expect(client.instance_variable_get(:@api_type)).to eq(GetblockioApi::Client::API_TYPE_JSON_RPC)
      expect(client.instance_variable_get(:@base_uri)).to eq(GetblockioApi::Client::DEFAULT_HTTP_BASE_URI)
    end
  end

  describe '#json_rpc_post' do
    let(:blockchain_path) { '' }
    let(:method) { 'eth_blockNumber' }
    let(:params) { [] }
    let(:response_body) { fixture('ethereum_block_number.json') }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}/#{blockchain_path}" }

    before do
      stub_request(:post, url.chomp('/'))
        .with(
          body: {
            jsonrpc: '2.0',
            method: method,
            params: params,
            id: 'getblock.io'
          }.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: response_body,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'sends a JSON-RPC request and returns the response' do
      response = client.json_rpc_post(blockchain_path, method, params)
      expect(response).to eq(JSON.parse(response_body)['result'])
    end

    it 'raises an error if API type is not JSON-RPC' do
      expect { rest_client.json_rpc_post(blockchain_path, method, params) }.to raise_error(ArgumentError)
    end
  end

  describe '#rest_get' do
    let(:path) { 'v1/info' }
    let(:query) { {} }
    let(:response_body) { fixture('aptos_get_info.json') }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}/#{path}" }

    before do
      stub_request(:get, url)
        .with(
          query: query,
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: response_body,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'sends a REST GET request and returns the response' do
      response = rest_client.rest_get(path, query)
      expect(response).to eq(JSON.parse(response_body))
    end

    it 'raises an error if API type is not REST' do
      expect { client.rest_get(path, query) }.to raise_error(ArgumentError)
    end
  end

  describe '#build_json_rpc_payload' do
    it 'builds a JSON-RPC payload with the correct format' do
      method = 'eth_blockNumber'
      params = []
      id = 'custom_id'

      payload = client.send(:build_json_rpc_payload, method, params, id)
      expect(payload).to eq({
        jsonrpc: '2.0',
        method: method,
        params: params,
        id: id
      }.to_json)
    end

    it 'uses default ID if not provided' do
      method = 'eth_blockNumber'
      params = []

      payload = client.send(:build_json_rpc_payload, method, params)
      expect(payload).to eq({
        jsonrpc: '2.0',
        method: method,
        params: params,
        id: 'getblock.io'
      }.to_json)
    end
  end
end
