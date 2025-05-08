require 'spec_helper'

RSpec.describe GetblockioApi::Solana do
  let(:api_key) { 'test_api_key' }
  let(:client) { GetblockioApi::Client.new(api_key: api_key, api_type: GetblockioApi::Client::API_TYPE_JSON_RPC) }
  let(:solana) { GetblockioApi::Solana.new(client) }

  describe '#get_balance' do
    let(:address) { '5D1fNXzvv5NjV1ysLjirC4WY92RNsVbxeCTqBmZPy7sh' }
    let(:commitment) { 'finalized' }
    let(:response_body) { fixture('solana_get_balance.json') }
    let(:expected_result) do
      {
        "context" => {
          "slot" => 171968590
        },
        "value" => 1000000000
      }
    end
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'getBalance',
            params: [address, { commitment: commitment }],
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
      expect(solana.get_balance(address, commitment)).to eq(expected_result)
    end
  end

  describe '#get_block_height' do
    let(:commitment) { 'finalized' }
    let(:response_body) do
      {
        jsonrpc: '2.0',
        id: 'getblock.io',
        result: 171968590
      }.to_json
    end
    let(:expected_result) { 171968590 }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'getBlockHeight',
            params: [{ commitment: commitment }],
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

    it 'returns the current block height' do
      expect(solana.get_block_height(commitment)).to eq(expected_result)
    end
  end

  describe '#get_latest_blockhash' do
    let(:commitment) { 'finalized' }
    let(:response_body) do
      {
        jsonrpc: '2.0',
        id: 'getblock.io',
        result: {
          context: {
            slot: 171968590
          },
          value: {
            blockhash: 'EkSnNWid2cvwEVnVx9aBqawnmiCNiDgp3gUdkDPTKN1N',
            lastValidBlockHeight: 171968690
          }
        }
      }.to_json
    end
    let(:expected_result) do
      {
        "context" => {
          "slot" => 171968590
        },
        "value" => {
          "blockhash" => "EkSnNWid2cvwEVnVx9aBqawnmiCNiDgp3gUdkDPTKN1N",
          "lastValidBlockHeight" => 171968690
        }
      }
    end
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'getLatestBlockhash',
            params: [{ commitment: commitment }],
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

    it 'returns the latest blockhash' do
      expect(solana.get_latest_blockhash(commitment)).to eq(expected_result)
    end
  end
end
