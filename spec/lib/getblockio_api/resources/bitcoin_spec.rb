require 'spec_helper'

RSpec.describe GetblockioApi::Bitcoin do
  let(:api_key) { 'test_api_key' }
  let(:client) { GetblockioApi::Client.new(api_key: api_key, api_type: GetblockioApi::Client::API_TYPE_JSON_RPC) }
  let(:bitcoin) { GetblockioApi::Bitcoin.new(client) }

  describe '#get_blockchain_info' do
    let(:response_body) { fixture('bitcoin_blockchain_info.json') }
    let(:expected_result) do
      {
        "chain" => "main",
        "blocks" => 788000,
        "headers" => 788000,
        "bestblockhash" => "00000000000000000002a7c4c1e48d76c5a37902165a270156b7a8d72728a054",
        "difficulty" => 53911173001054.59,
        "mediantime" => 1682521611,
        "verificationprogress" => 0.9999997486272058,
        "initialblockdownload" => false,
        "chainwork" => "00000000000000000000000000000000000000002a36f8a8c1e0f9dc5e827e2d",
        "size_on_disk" => 491728829884,
        "pruned" => false,
        "warnings" => ""
      }
    end
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'getblockchaininfo',
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

    it 'returns the blockchain info' do
      expect(bitcoin.get_blockchain_info).to eq(expected_result)
    end
  end

  describe '#get_block_count' do
    let(:response_body) do
      {
        jsonrpc: '2.0',
        id: 'getblock.io',
        result: 788000
      }.to_json
    end
    let(:expected_result) { 788000 }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'getblockcount',
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

    it 'returns the current block count' do
      expect(bitcoin.get_block_count).to eq(expected_result)
    end
  end

  describe '#abort_rescan' do
    let(:response_body) do
      {
        jsonrpc: '2.0',
        id: 'getblock.io',
        result: true
      }.to_json
    end
    let(:expected_result) { true }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'abortrescan',
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

    it 'aborts the current rescan' do
      expect(bitcoin.abort_rescan).to eq(expected_result)
    end
  end
end
