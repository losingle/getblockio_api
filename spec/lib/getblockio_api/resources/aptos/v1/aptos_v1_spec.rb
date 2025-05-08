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
          body: response_body,
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
          body: response_body,
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
          body: response_body,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'returns the account resources' do
      expect(aptos_v1.get_account_resources(address)).to eq(expected_result)
    end
  end
end
