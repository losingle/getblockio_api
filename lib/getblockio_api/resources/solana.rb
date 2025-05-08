module GetblockioApi
  # Solana Resource class
  class Solana < Resource
    BLOCKCHAIN_PATH = ''.freeze  # Solana uses an empty path, differentiated by API key

    # Get account information
    # @param pubkey [String] Public key
    # @param commitment [String] Commitment level (default: "finalized")
    # @return [Hash] Account information
    def get_account_info(pubkey, commitment = 'finalized')
      json_rpc('getAccountInfo', [pubkey, { commitment: commitment }])
    end

    # Get balance
    # @param pubkey [String] Public key
    # @param commitment [String] Commitment level (default: "finalized")
    # @return [Integer] Balance (in lamports)
    def get_balance(pubkey, commitment = 'finalized')
      json_rpc('getBalance', [pubkey, { commitment: commitment }])
    end

    # Get block
    # @param slot [Integer] Slot number
    # @param commitment [String] Commitment level (default: "finalized")
    # @return [Hash] Block information
    def get_block(slot, commitment = 'finalized')
      json_rpc('getBlock', [slot, { commitment: commitment }])
    end

    # Get block height
    # @param commitment [String] Commitment level (default: "finalized")
    # @return [Integer] Block height
    def get_block_height(commitment = 'finalized')
      json_rpc('getBlockHeight', [{ commitment: commitment }])
    end

    # Get latest blockhash
    # @param commitment [String] Commitment level (default: "finalized")
    # @return [String] Block hash
    def get_latest_blockhash(commitment = 'finalized')
      json_rpc('getLatestBlockhash', [{ commitment: commitment }])
    end

    # Get transaction
    # @param signature [String] Transaction signature
    # @param commitment [String] Commitment level (default: "finalized")
    # @return [Hash] Transaction information
    def get_transaction(signature, commitment = 'finalized')
      json_rpc('getTransaction', [signature, { commitment: commitment }])
    end

    # Send transaction
    # @param encoded_tx [String] Base64 encoded transaction
    # @param commitment [String] Commitment level (default: "finalized")
    # @return [String] Transaction signature
    def send_transaction(encoded_tx, commitment = 'finalized')
      json_rpc('sendTransaction', [encoded_tx, { encoding: 'base64', commitment: commitment }])
    end

    # Get token account balance
    # @param pubkey [String] Token account public key
    # @param commitment [String] Commitment level (default: "finalized")
    # @return [Hash] Token balance information
    def get_token_account_balance(pubkey, commitment = 'finalized')
      json_rpc('getTokenAccountBalance', [pubkey, { commitment: commitment }])
    end

    # Get program accounts
    # @param program_id [String] Program ID
    # @param commitment [String] Commitment level (default: "finalized")
    # @return [Array] List of program accounts
    def get_program_accounts(program_id, commitment = 'finalized')
      json_rpc('getProgramAccounts', [program_id, { commitment: commitment }])
    end

    # Subscribe to account changes
    # @param pubkey [String] Public key
    # @param commitment [String] Commitment level (default: "finalized")
    # @param callback [Block] Callback for handling subscription messages
    # @return [String] Subscription ID
    def subscribe_account(pubkey, commitment = 'finalized', &callback)
      subscribe('accountSubscribe', [pubkey, { commitment: commitment }], &callback)
    end

    # Subscribe to program
    # @param program_id [String] Program ID
    # @param commitment [String] Commitment level (default: "finalized")
    # @param callback [Block] Callback for handling subscription messages
    # @return [String] Subscription ID
    def subscribe_program(program_id, commitment = 'finalized', &callback)
      subscribe('programSubscribe', [program_id, { commitment: commitment }], &callback)
    end
  end
end
