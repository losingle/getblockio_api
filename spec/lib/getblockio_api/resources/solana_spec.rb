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

  describe '#get_fee_for_message' do
    let(:message) { 'AQABAgIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgABAQICAQACAQMDAQYDAAgJAQkLAQAAAAAAAAMDAgABAAQCBgADAQACAgABAgECAAQDAAEBAgABAwACAgABAwEBBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUF' } # Example base64 message
    let(:options) { { commitment: 'confirmed', min_context_slot: 123456 } }
    let(:response_body) do
      {
        jsonrpc: '2.0',
        id: 'getblock.io',
        result: {
          context: {
            slot: 123456789
          },
          value: 5000
        }
      }.to_json
    end
    let(:expected_result) do
      {
        "context" => {
          "slot" => 123456789
        },
        "value" => 5000
      }
    end
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'getFeeForMessage',
            params: [message, { commitment: options[:commitment], minContextSlot: options[:min_context_slot] }],
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

    it 'returns the fee for the given message with options' do
      expect(solana.get_fee_for_message(message, options)).to eq(expected_result)
    end
  end

  describe '#get_minimum_balance_for_rent_exemption' do
    let(:data_size) { 128 } # Example data size
    let(:options) { { commitment: 'processed' } }
    let(:response_body) do
      {
        jsonrpc: '2.0',
        id: 'getblock.io',
        result: 1234567 # Example lamport amount
      }.to_json
    end
    let(:expected_result) { 1234567 }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'getMinimumBalanceForRentExemption',
            params: [data_size, options],
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

    it 'returns the minimum balance for rent exemption with options' do
      expect(solana.get_minimum_balance_for_rent_exemption(data_size, options)).to eq(expected_result)
    end
  end

  describe '#get_recent_performance_samples' do
    let(:options) { { limit: 10 } }
    let(:response_body) do
      {
        jsonrpc: '2.0',
        id: 'getblock.io',
        result: [
          { slot: 123, numTransactions: 5, numSlots: 1, samplePeriodSecs: 60 },
          { slot: 124, numTransactions: 8, numSlots: 1, samplePeriodSecs: 60 }
        ]
      }.to_json
    end
    let(:expected_result) do
      [
        { "slot" => 123, "numTransactions" => 5, "numSlots" => 1, "samplePeriodSecs" => 60 },
        { "slot" => 124, "numTransactions" => 8, "numSlots" => 1, "samplePeriodSecs" => 60 }
      ]
    end
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    context 'with limit option' do
      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              method: 'getRecentPerformanceSamples',
              params: [options[:limit]], # Limit is passed directly in params array
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

      it 'returns recent performance samples with limit' do
        expect(solana.get_recent_performance_samples(options)).to eq(expected_result)
      end
    end

    context 'without limit option (testing default behavior)' do
      let(:options_empty) { {} }
      let(:response_body_default) do # Potentially different or same response for default
        {
          jsonrpc: '2.0',
          id: 'getblock.io',
          result: [
            { slot: 125, numTransactions: 10, numSlots: 1, samplePeriodSecs: 60 }
          ]
        }.to_json
      end
      let(:expected_result_default) do
        [
          { "slot" => 125, "numTransactions" => 10, "numSlots" => 1, "samplePeriodSecs" => 60 }
        ]
      end

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              method: 'getRecentPerformanceSamples',
              params: [], # Empty params array when no limit is specified
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
            body: response_body_default,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns recent performance samples with default limit' do
        expect(solana.get_recent_performance_samples(options_empty)).to eq(expected_result_default)
      end
    end
  end

  describe '#get_slot' do
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    context 'with options' do
      let(:options) { { commitment: 'processed', min_context_slot: 98765 } }
      let(:response_body) do
        {
          jsonrpc: '2.0',
          id: 'getblock.io',
          result: 180000000 # Example slot number
        }.to_json
      end
      let(:expected_result) { 180000000 }

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              method: 'getSlot',
              params: [{ commitment: options[:commitment], minContextSlot: options[:min_context_slot] }],
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

      it 'returns the current slot with specified options' do
        expect(solana.get_slot(options)).to eq(expected_result)
      end
    end

    context 'without options (testing default behavior)' do
      let(:options_empty) { {} }
      let(:response_body_default) do
        {
          jsonrpc: '2.0',
          id: 'getblock.io',
          result: 180000005 # Example slot number for default call
        }.to_json
      end
      let(:expected_result_default) { 180000005 }

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              method: 'getSlot',
              params: [], # Empty params array for default options
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
            body: response_body_default,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns the current slot with default options' do
        expect(solana.get_slot(options_empty)).to eq(expected_result_default)
      end
    end
  end

  describe '#get_slot_leader' do
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    context 'with options' do
      let(:options) { { commitment: 'finalized', min_context_slot: 12345 } }
      let(:response_body) do
        {
          jsonrpc: '2.0',
          id: 'getblock.io',
          result: 'SomeSlotLeaderPublicKey123456789'
        }.to_json
      end
      let(:expected_result) { 'SomeSlotLeaderPublicKey123456789' }

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              method: 'getSlotLeader',
              params: [{ commitment: options[:commitment], minContextSlot: options[:min_context_slot] }],
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

      it 'returns the current slot leader with specified options' do
        expect(solana.get_slot_leader(options)).to eq(expected_result)
      end
    end

    context 'without options (testing default behavior)' do
      let(:options_empty) { {} }
      let(:response_body_default) do
        {
          jsonrpc: '2.0',
          id: 'getblock.io',
          result: 'DefaultSlotLeaderPublicKeyABCDEFG'
        }.to_json
      end
      let(:expected_result_default) { 'DefaultSlotLeaderPublicKeyABCDEFG' }

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              method: 'getSlotLeader',
              params: [], # Empty params array for default options
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
            body: response_body_default,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns the current slot leader with default options' do
        expect(solana.get_slot_leader(options_empty)).to eq(expected_result_default)
      end
    end
  end

  describe '#get_max_shred_insert_slot' do
    let(:response_body) do
      {
        jsonrpc: '2.0',
        id: 'getblock.io',
        result: 200000000 # Example max shred insert slot
      }.to_json
    end
    let(:expected_result) { 200000000 }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    before do
      stub_request(:post, url)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'getMaxShredInsertSlot',
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

    it 'returns the max shred insert slot' do
      expect(solana.get_max_shred_insert_slot).to eq(expected_result)
    end
  end

  describe '#get_multiple_accounts' do
    let(:pubkeys) { ['PubKey123', 'PubKey456'] }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }

    context 'with options' do
      let(:options) do
        {
          commitment: 'confirmed',
          min_context_slot: 55555,
          data_slice: { offset: 0, length: 10 },
          encoding: 'base64'
        }
      end
      let(:response_body) do
        {
          jsonrpc: '2.0',
          id: 'getblock.io',
          result: {
            context: { slot: 190000000 },
            value: [
              { lamports: 100, owner: 'Owner1', data: ['data1', 'base64'], executable: false, rentEpoch: 100, space: 10 },
              nil # Example of a non-existent account
            ]
          }
        }.to_json
      end
      let(:expected_result) do
        {
          "context" => { "slot" => 190000000 },
          "value" => [
            { "lamports" => 100, "owner" => "Owner1", "data" => ["data1", "base64"], "executable" => false, "rentEpoch" => 100, "space" => 10 },
            nil
          ]
        }
      end

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              method: 'getMultipleAccounts',
              params: [
                pubkeys,
                {
                  commitment: options[:commitment],
                  encoding: options[:encoding],
                  dataSlice: options[:data_slice],
                  minContextSlot: options[:min_context_slot]
                }
              ],
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

      it 'returns multiple account info with specified options' do
        expect(solana.get_multiple_accounts(pubkeys, options)).to eq(expected_result)
      end
    end

    context 'without options (testing default behavior)' do
      let(:options_empty) { {} }
      let(:response_body_default) do
        {
          jsonrpc: '2.0',
          id: 'getblock.io',
          result: {
            context: { slot: 190000005 },
            value: [
              { lamports: 200, owner: 'Owner2', data: ['data2', 'base64'], executable: true, rentEpoch: 101, space: 20 },
              { lamports: 300, owner: 'Owner3', data: ['data3', 'base64'], executable: false, rentEpoch: 102, space: 30 }
            ]
          }
        }.to_json
      end
      let(:expected_result_default) do
        {
          "context" => { "slot" => 190000005 },
          "value" => [
            { "lamports" => 200, "owner" => "Owner2", "data" => ["data2", "base64"], "executable" => true, "rentEpoch" => 101, "space" => 20 },
            { "lamports" => 300, "owner" => "Owner3", "data" => ["data3", "base64"], "executable" => false, "rentEpoch" => 102, "space" => 30 }
          ]
        }
      end

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              method: 'getMultipleAccounts',
              params: [pubkeys], # Only pubkeys, no options object
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
            body: response_body_default,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns multiple account info with default options' do
        expect(solana.get_multiple_accounts(pubkeys, options_empty)).to eq(expected_result_default)
      end
    end
  end

  describe '#get_program_accounts' do
    let(:program_id) { 'ProgramId123456789' }
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }
    let(:sample_account) do
      {
        pubkey: 'AccountPubKey1',
        account: {
          lamports: 1000,
          data: ['account data', 'base64'],
          owner: program_id,
          executable: false,
          rentEpoch: 200
        }
      }
    end
    let(:expected_sample_account) do
      {
        "pubkey" => 'AccountPubKey1',
        "account" => {
          "lamports" => 1000,
          "data" => ['account data', 'base64'],
          "owner" => program_id,
          "executable" => false,
          "rentEpoch" => 200
        }
      }
    end

    context 'with comprehensive options' do
      let(:options) do
        {
          commitment: 'finalized',
          encoding: 'base64',
          data_slice: { offset: 8, length: 32 },
          filters: [
            { memcmp: { offset: 0, bytes: 'somebytes' } },
            { dataSize: 128 }
          ],
          with_context: true,
          min_context_slot: 60000
        }
      end
      let(:response_body) do
        {
          jsonrpc: '2.0',
          id: 'getblock.io',
          result: {
            context: { slot: 200000000 },
            value: [sample_account]
          }
        }.to_json
      end
      let(:expected_result) do
        {
          "context" => { "slot" => 200000000 },
          "value" => [expected_sample_account]
        }
      end

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              method: 'getProgramAccounts',
              params: [
                program_id,
                {
                  commitment: options[:commitment],
                  encoding: options[:encoding],
                  filters: options[:filters],
                  dataSlice: options[:data_slice],
                  withContext: options[:with_context],
                  minContextSlot: options[:min_context_slot]
                }
              ],
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

      it 'returns program accounts with comprehensive options' do
        expect(solana.get_program_accounts(program_id, options)).to eq(expected_result)
      end
    end

    context 'with minimal options (e.g., only commitment)' do
      let(:options_minimal) { { commitment: 'confirmed' } }
      let(:response_body_minimal) do
        {
          jsonrpc: '2.0',
          id: 'getblock.io',
          result: [sample_account] # No context wrapper
        }.to_json
      end
      let(:expected_result_minimal) { [expected_sample_account] }

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              method: 'getProgramAccounts',
              params: [program_id, { commitment: options_minimal[:commitment] }],
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
            body: response_body_minimal,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns program accounts with minimal options' do
        expect(solana.get_program_accounts(program_id, options_minimal)).to eq(expected_result_minimal)
      end
    end

    context 'without any options (empty options hash)' do
      let(:options_empty) { {} }
      let(:response_body_default) do
        {
          jsonrpc: '2.0',
          id: 'getblock.io',
          result: [sample_account] # No context wrapper, default commitment/encoding assumed by RPC
        }.to_json
      end
      let(:expected_result_default) { [expected_sample_account] }

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              method: 'getProgramAccounts',
              params: [program_id], # Params array contains only program_id
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
            body: response_body_default,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns program accounts with default behavior for empty options' do
        expect(solana.get_program_accounts(program_id, options_empty)).to eq(expected_result_default)
      end
    end
  end

  describe '#get_recent_prioritization_fees' do
    let(:url) { "#{GetblockioApi::Client::DEFAULT_HTTP_BASE_URI}#{api_key}" }
    let(:sample_fee_entry) { { slot: 300000000, prioritizationFee: 10000 } }
    let(:expected_sample_fee_entry) { { "slot" => 300000000, "prioritizationFee" => 10000 } }

    context 'with locked_writable_accounts' do
      let(:locked_accounts) { ['AccPubKey789', 'AccPubKeyABC'] }
      let(:response_body) do
        {
          jsonrpc: '2.0',
          id: 'getblock.io',
          result: [sample_fee_entry, { slot: 300000001, prioritizationFee: 12000 }]
        }.to_json
      end
      let(:expected_result) { [expected_sample_fee_entry, { "slot" => 300000001, "prioritizationFee" => 12000 }] }

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              method: 'getRecentPrioritizationFees',
              params: [locked_accounts],
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

      it 'returns recent prioritization fees for specified accounts' do
        expect(solana.get_recent_prioritization_fees(locked_accounts)).to eq(expected_result)
      end
    end

    context 'without locked_writable_accounts (default behavior)' do
      let(:response_body_default) do
        {
          jsonrpc: '2.0',
          id: 'getblock.io',
          result: [sample_fee_entry]
        }.to_json
      end
      let(:expected_result_default) { [expected_sample_fee_entry] }

      before do
        stub_request(:post, url)
          .with(
            body: {
              jsonrpc: '2.0',
              method: 'getRecentPrioritizationFees',
              params: [], # Empty params array
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
            body: response_body_default,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns recent prioritization fees with default behavior' do
        expect(solana.get_recent_prioritization_fees).to eq(expected_result_default)
      end
    end
  end
end
