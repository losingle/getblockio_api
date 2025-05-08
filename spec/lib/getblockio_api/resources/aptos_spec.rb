require 'spec_helper'

RSpec.describe GetblockioApi::Aptos do
  let(:api_key) { 'test_api_key' }
  let(:client) { GetblockioApi::Client.new(api_key: api_key, api_type: GetblockioApi::Client::API_TYPE_REST) }
  
  describe '.new' do
    it 'creates a v1 instance by default' do
      aptos = GetblockioApi::Aptos.new(client)
      expect(aptos).to be_a(GetblockioApi::AptosV1)
    end
    
    it 'creates a v1 instance when specified' do
      aptos = GetblockioApi::Aptos.new(client, 'v1')
      expect(aptos).to be_a(GetblockioApi::AptosV1)
    end
    
    it 'raises an error for unsupported versions' do
      expect { GetblockioApi::Aptos.new(client, 'v2') }.to raise_error(ArgumentError)
    end
  end
end
