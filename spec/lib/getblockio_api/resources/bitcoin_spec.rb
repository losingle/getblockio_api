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

  describe '#get_best_block_hash' do
    let(:response_body) do
      {
        jsonrpc: '2.0',
        id: 'getblock.io',
        result: '00000000000000000002a7c4c1e48d76c5a37902165a270156b7a8d72728a054'
      }.to_json
    end
    let(:expected_result) { '00000000000000000002a7c4c1e48d76c5a37902165a270156b7a8d72728a054' }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'getbestblockhash',
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

    it 'returns the best block hash' do
      expect(bitcoin.get_best_block_hash).to eq(expected_result)
    end
  end

  describe '#get_difficulty' do
    let(:response_body) do
      {
        jsonrpc: '2.0',
        id: 'getblock.io',
        result: 303127737690.0432
      }.to_json
    end
    let(:expected_result) { 303127737690.0432 }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'getdifficulty',
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

    it 'returns the current difficulty' do
      expect(bitcoin.get_difficulty).to eq(expected_result)
    end
  end

  describe '#get_block_header' do
    let(:block_hash) { '000000000000000000046b9302e08c16ea186950f42a5498320ddd1bd7ab3428' }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    context 'when verbose is true (default)' do
      let(:verbose_flag) { true }
      let(:response_body) do
        {
          jsonrpc: '2.0',
          id: 'getblock.io',
          result: {
            hash: block_hash,
            confirmations: 1,
            height: 600000,
            version: 536870912,
            versionHex: '20000000',
            merkleroot: 'f8b7a8c3b9e0d7f6a2c5d4e1f3b9c7a6f0d5c3b2a1d0e9f8c7b6a5d4e3f2a1b0',
            time: 1600000000,
            mediantime: 1599999000,
            nonce: 0,
            bits: '1d00ffff',
            difficulty: 1,
            chainwork: '0000000000000000000000000000000000000000000000000000000100010001',
            nTx: 1,
            previousblockhash: '0000000000000000000000000000000000000000000000000000000000000000',
            nextblockhash: '0000000000000000000123456789abcdef0123456789abcdef0123456789a'
          }
        }.to_json
      end
      let(:expected_result) { JSON.parse(response_body)['result'] }

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              method: 'getblockheader',
              params: [block_hash, verbose_flag],
              id: 'getblock.io'
            }.to_json
          )
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns the block header as a JSON object' do
        expect(bitcoin.get_block_header(block_hash)).to eq(expected_result) # Test default verbose
        expect(bitcoin.get_block_header(block_hash, true)).to eq(expected_result) # Test explicit verbose true
      end
    end

    context 'when verbose is false' do
      let(:verbose_flag) { false }
      let(:response_body) do
        {
          jsonrpc: '2.0',
          id: 'getblock.io',
          result: '000000200000000000000000000000000000000000000000000000000000000000000000b0a1f2e3d4c5b6a7f8e9d0a1b2c3d4e5f6a7b8c9d0e1f2a300000000ffff001d00000000'
        }.to_json
      end
      let(:expected_result) { JSON.parse(response_body)['result'] }

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              method: 'getblockheader',
              params: [block_hash, verbose_flag],
              id: 'getblock.io'
            }.to_json
          )
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns the block header as a hex string' do
        expect(bitcoin.get_block_header(block_hash, false)).to eq(expected_result)
      end
    end
  end

  describe '#get_chain_tips' do
    let(:response_body) do
      {
        jsonrpc: '2.0',
        id: 'getblock.io',
        result: [
          {
            height: 684634,
            hash: '0000000000000000023a561e1ea370153aac5d1504726d1a039032831c05fcfc',
            branchlen: 0,
            status: 'active'
          },
          {
            height: 683516,
            hash: '000000000000000001d3a318372df5d1eec54462a0d7471ae1cdf49838f793dd',
            branchlen: 1,
            status: 'valid-headers'
          }
        ]
      }.to_json
    end
    let(:expected_result) { JSON.parse(response_body)['result'] }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'getchaintips',
            params: [],
            id: 'getblock.io'
          }.to_json
        )
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns the chain tips' do
      expect(bitcoin.get_chain_tips).to eq(expected_result)
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
