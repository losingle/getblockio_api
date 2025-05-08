require 'spec_helper'

RSpec.describe GetblockioApi::AptosV1 do
  let(:api_key) { 'test_api_key' }
  let(:client) { GetblockioApi::Client.new(api_key: api_key, api_type: GetblockioApi::Client::API_TYPE_REST) }
  let(:aptos_v1) { GetblockioApi::AptosV1.new(client) }

  describe '#get_info' do
    let(:response_body) { fixture('aptos_get_info.json') }
    let(:expected_result) do
      {
        "chain_id" => 1,
        "epoch" => "1",
        "ledger_version" => "1000000",
        "oldest_ledger_version" => "0",
        "ledger_timestamp" => "1682521611000000",
        "node_role" => "full_node",
        "oldest_block_height" => "0",
        "block_height" => "100000",
        "git_hash" => "8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b"
      }
    end
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}/v1/info" }

    before do
      stub_request(:get, url)
        .with(
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(
          status: 200,
          body: response_body.is_a?(String) ? response_body : response_body.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'returns the Aptos node info' do
      expect(aptos_v1.get_info).to eq(expected_result)
    end
  end

  describe '#get_account' do
    let(:address) { '0x1' }
    let(:ledger_version) { nil }
    let(:response_body) do
      {
        sequence_number: "0",
        authentication_key: "0x1111111111111111111111111111111111111111111111111111111111111111"
      }.to_json
    end
    let(:expected_result) do
      {
        "sequence_number" => "0",
        "authentication_key" => "0x1111111111111111111111111111111111111111111111111111111111111111"
      }
    end
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}/v1/accounts/#{address}" }

    before do
      stub_request(:get, url)
        .with(
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(
          status: 200,
          body: response_body.is_a?(String) ? response_body : response_body.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'returns the account info' do
      expect(aptos_v1.get_account(address)).to eq(expected_result)
    end
  end

  describe '#get_account_resources' do
    let(:address) { '0x1' }
    let(:ledger_version) { nil }
    let(:response_body) do
      [
        {
          type: "0x1::account::Account",
          data: {
            authentication_key: "0x1111111111111111111111111111111111111111111111111111111111111111",
            sequence_number: "0"
          }
        }
      ].to_json
    end
    let(:expected_result) do
      [
        {
          "type" => "0x1::account::Account",
          "data" => {
            "authentication_key" => "0x1111111111111111111111111111111111111111111111111111111111111111",
            "sequence_number" => "0"
          }
        }
      ]
    end
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}/v1/accounts/#{address}/resources" }

    before do
      stub_request(:get, url)
        .with(
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(
          status: 200,
          body: response_body.is_a?(String) ? response_body : response_body.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'returns the account resources' do
      expect(aptos_v1.get_account_resources(address)).to eq(expected_result)
    end
  end

  describe '#get_account_events_by_creation_number' do
    let(:address) { '0xabc' }
    let(:creation_number) { '123' }
    let(:limit) { 10 }
    let(:start) { 5 }
    let(:response_body) { [{ type: '0x1::coin::DepositEvent', data: { amount: '100' } }].to_json }
    let(:expected_result) { [{ 'type' => '0x1::coin::DepositEvent', 'data' => { 'amount' => '100' } }] }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}/v1/accounts/#{address}/events/#{creation_number}?limit=#{limit}&start=#{start}" }

    before do
      stub_request(:get, url)
        .to_return(status: 200, body: response_body.is_a?(String) ? response_body : response_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns account events by creation number' do
      expect(aptos_v1.get_account_events_by_creation_number(address, creation_number, limit, start)).to eq(expected_result)
    end
  end

  describe '#get_account_module' do
    let(:address) { '0xdef' }
    let(:module_name) { 'my_module' }
    let(:response_body) { { bytecode: '0x...', abi: {} }.to_json }
    let(:expected_result) { { 'bytecode' => '0x...', 'abi' => {} } }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}/v1/accounts/#{address}/module/#{module_name}" }

    before do
      stub_request(:get, url)
        .to_return(status: 200, body: response_body.is_a?(String) ? response_body : response_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns account module ABI and bytecode' do
      expect(aptos_v1.get_account_module(address, module_name)).to eq(expected_result)
    end
  end

  describe '#get_account_resource' do
    let(:address) { '0xghi' }
    let(:resource_type) { '0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>' }
    let(:url_encoded_resource_type) { CGI.escape(resource_type) }
    let(:response_body) { { type: resource_type, data: { coin: { value: '123' } } }.to_json }
    let(:expected_result) { { 'type' => resource_type, 'data' => { 'coin' => { 'value' => '123' } } } }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}/v1/accounts/#{address}/resource/#{url_encoded_resource_type}" }

    before do
      stub_request(:get, url)
        .to_return(status: 200, body: response_body.is_a?(String) ? response_body : response_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns account resource by type' do
      expect(aptos_v1.get_account_resource(address, resource_type)).to eq(expected_result)
    end
  end

  describe '#get_block_by_version' do
    let(:version) { 98765 }
    let(:with_transactions) { true }
    let(:response_body) { { block_height: '100', transactions: [{ hash: '0x123' }] }.to_json }
    let(:expected_result) { { 'block_height' => '100', 'transactions' => [{ 'hash' => '0x123' }] } }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}/v1/blocks/by_version/#{version}?with_transactions=#{with_transactions}" }

    before do
      stub_request(:get, url)
        .to_return(status: 200, body: response_body.is_a?(String) ? response_body : response_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns block by version' do
      expect(aptos_v1.get_block_by_version(version, with_transactions)).to eq(expected_result)
    end
  end

  describe '#estimate_gas_price' do
    let(:response_body) { { gas_estimate: 100 }.to_json }
    let(:expected_result) { { 'gas_estimate' => 100 } }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}/v1/estimate_gas_price" }

    before do
      stub_request(:get, url)
        .to_return(status: 200, body: response_body.is_a?(String) ? response_body : response_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns gas price estimation' do
      expect(aptos_v1.estimate_gas_price).to eq(expected_result)
    end
  end

  describe '#get_transaction_by_version' do
    let(:version) { 12345 }
    let(:response_body) { { version: version.to_s, hash: '0xtest_hash' }.to_json }
    let(:expected_result) { { 'version' => version.to_s, 'hash' => '0xtest_hash' } }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}/v1/transactions/by_version/#{version}" }

    before do
      stub_request(:get, url)
        .to_return(status: 200, body: response_body.is_a?(String) ? response_body : response_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns transaction by version' do
      expect(aptos_v1.get_transaction_by_version(version)).to eq(expected_result)
    end
  end

  describe '#submit_transaction' do
    let(:payload) { { sender: '0x1', sequence_number: '0', payload: { function: '0x1::coin::transfer', arguments: ['0x2', '100'] } } }
    let(:response_body) { { hash: '0xsubmitted_tx_hash', success: true }.to_json }
    let(:expected_result) { { 'hash' => '0xsubmitted_tx_hash', 'success' => true } }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}/v1/transactions" }

    before do
      stub_request(:post, url)
        .with(body: payload.to_json, headers: { 'Content-Type' => 'application/json' })
        .to_return(status: 200, body: response_body.is_a?(String) ? response_body : response_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'submits a JSON transaction' do
      expect(aptos_v1.submit_transaction(payload)).to eq(expected_result)
    end
  end

  describe '#submit_bcs_transaction' do
    let(:bcs_payload) { '0x0102030405' }
    let(:response_body) { { hash: '0xsubmitted_bcs_tx_hash', success: true }.to_json }
    let(:expected_result) { { 'hash' => '0xsubmitted_bcs_tx_hash', 'success' => true } }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}/v1/transactions" }

    before do
      stub_request(:post, url)
        .with(body: bcs_payload, headers: { 'Content-Type' => 'application/x.aptos.signed_transaction+bcs' })
        .to_return(status: 200, body: response_body.is_a?(String) ? response_body : response_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'submits a BCS transaction' do
      expect(aptos_v1.submit_bcs_transaction(bcs_payload)).to eq(expected_result)
    end
  end

  describe '#submit_batch_transactions' do
    let(:payloads) do
      [
        { sender: '0x1', sequence_number: '1', payload: { function: '0x1::coin::transfer', arguments: ['0x3', '200'] } },
        { sender: '0x1', sequence_number: '2', payload: { function: '0x1::coin::transfer', arguments: ['0x4', '300'] } }
      ]
    end
    let(:response_body) { [{ hash: '0xbatch_tx1', success: true }, { hash: '0xbatch_tx2', success: true }].to_json }
    let(:expected_result) { [{ 'hash' => '0xbatch_tx1', 'success' => true }, { 'hash' => '0xbatch_tx2', 'success' => true }] }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}/v1/transactions/batch" }

    before do
      stub_request(:post, url)
        .with(body: payloads.to_json, headers: { 'Content-Type' => 'application/json' })
        .to_return(status: 200, body: response_body.is_a?(String) ? response_body : response_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'submits batch JSON transactions' do
      expect(aptos_v1.submit_batch_transactions(payloads)).to eq(expected_result)
    end
  end
end
