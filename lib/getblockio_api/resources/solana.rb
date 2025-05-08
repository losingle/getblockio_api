module GetblockioApi
  # Solana Resource class
  class Solana < Resource
    BLOCKCHAIN_PATH = ''.freeze  # Solana uses an empty path, differentiated by API key

    # Get account information
    # Retrieves all metadata associated with an account, such as lamports (balance), owner, data, and rentEpoch.
    # @param pubkey [String] Public key of the account to query, as a base-58 encoded string.
    # @param options [Hash] Optional parameters.
    # @option options [String] :commitment Commitment level. Valid values are "processed", "confirmed", or "finalized" (default).
    # @option options [String] :encoding Encoding for account data. Valid values are "base58" (default), "base64", "base64+zstd", or "jsonParsed".
    # @option options [Hash] :data_slice Limit the returned account data. This hash should contain:
    #   * :offset [Integer] Starting byte of the account data to return.
    #   * :length [Integer] Number of bytes of account data to return.
    # @option options [Integer] :min_context_slot The minimum slot at which the request should be evaluated.
    # @return [Hash] A hash containing the account information or null if the account does not exist.
    #   The result object has a `context` and `value` field. The `value` field contains:
    #   * `lamports` [Integer] Balance in lamports.
    #   * `owner` [String] Program ID owning the account (base-58 encoded).
    #   * `data` [Array, Hash] Account data, format depends on encoding. For `jsonParsed`, this is a hash.
    #   * `executable` [Boolean] Whether the account contains a program.
    #   * `rentEpoch` [Integer] Epoch at which rent is due.
    #   * `space` [Integer] Size of account data in bytes.
    def get_account_info(pubkey, options = {})
      rpc_options = options.dup
      rpc_options[:dataSlice] = rpc_options.delete(:data_slice) if rpc_options.key?(:data_slice)
      rpc_options[:minContextSlot] = rpc_options.delete(:min_context_slot) if rpc_options.key?(:min_context_slot)
      json_rpc('getAccountInfo', [pubkey, rpc_options])
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

    # Subscribe to account changes.
    # Provides a subscription ID that can be used to unsubscribe later.
    # The notification format is similar to the getAccountInfo method's response.
    # @param pubkey [String] The account Pubkey as a base-58 encoded string.
    # @param options [Hash] Optional parameters.
    # @option options [String] :commitment Commitment level to observe (e.g., "finalized", "confirmed", "processed").
    # @option options [String] :encoding The encoding format for the account data (e.g., "base58", "base64", "base64+zstd", "jsonParsed").
    # @param callback [Block] Callback for handling subscription messages. The callback will receive a hash representing the notification.
    # @return [Integer] The subscription ID.
    def subscribe_account(pubkey, options = {}, &callback)
      # maps to accountSubscribe RPC method
      subscribe('accountSubscribe', [pubkey, options], &callback)
    end

    # Unsubscribe from account changes.
    # Stops real-time updates for a subscribed account in Solana’s WebSocket API.
    # @param subscription_id [Integer] The subscription ID previously received from `subscribe_account`.
    # @return [Hash] A hash containing a boolean `result` indicating if the unsubscribe was successful.
    def unsubscribe_account(subscription_id)
      # maps to accountUnsubscribe RPC method
      json_rpc('accountUnsubscribe', [subscription_id])
    end

    # Subscribe to block updates.
    # Note: This method is considered unstable and requires the validator to be started with the `--rpc-pubsub-enable-block-subscription` flag.
    # Future changes to this method's format are possible.
    # @param filter [String, Hash] Filter criteria. This can be:
    #   - The string "all" to receive notifications for all blocks.
    #   - A Hash `{ mentionsAccountOrProgram: "ACCOUNT_OR_PROGRAM_PUBKEY" }` to receive notifications for blocks that mention the given account or program (base-58 encoded string).
    # @param options [Hash] Optional parameters for the subscription.
    # @option options [String] :commitment Commitment level for block finality (e.g., "finalized" (default), "confirmed", "processed").
    # @option options [String] :encoding Transaction encoding format (default: "json", supported: "json", "jsonParsed", "base58", "base64").
    # @option options [String] :transaction_details Level of transaction detail to return (default: "full", supported: "full", "accounts", "signatures", "none").
    # @option options [Boolean] :show_rewards Whether to include block rewards in the notification (default: true).
    # @option options [Integer] :max_supported_transaction_version The maximum transaction version to return. If not specified, transactions of all versions are returned.
    # @param callback [Block] Callback for handling subscription messages. The callback will receive a hash representing the block notification.
    # @return [Integer] The subscription ID.
    def subscribe_block(filter, options = {}, &callback)
      # maps to blockSubscribe RPC method
      rpc_options = options.dup
      rpc_options[:transactionDetails] = rpc_options.delete(:transaction_details) if rpc_options.key?(:transaction_details)
      rpc_options[:showRewards] = rpc_options.delete(:show_rewards) if rpc_options.key?(:show_rewards)
      rpc_options[:maxSupportedTransactionVersion] = rpc_options.delete(:max_supported_transaction_version) if rpc_options.key?(:max_supported_transaction_version)

      params = [filter]
      params << rpc_options unless rpc_options.empty?

      subscribe('blockSubscribe', params, &callback)
    end

    # Unsubscribe from block updates.
    # Cancels an active block subscription using its subscription ID.
    # @param subscription_id [Integer] The subscription ID previously received from `subscribe_block`.
    # @return [Hash] A hash containing a boolean `result` indicating if the unsubscribe was successful.
    def unsubscribe_block(subscription_id)
      # maps to blockUnsubscribe RPC method
      json_rpc('blockUnsubscribe', [subscription_id])
    end

    # Subscribe to program
    # @param program_id [String] Program ID
    # @param commitment [String] Commitment level (default: "finalized")
    # @param callback [Block] Callback for handling subscription messages
    # @return [String] Subscription ID
    def subscribe_program(program_id, commitment = 'finalized', &callback)
      subscribe('programSubscribe', [program_id, { commitment: commitment }], &callback)
    end

    # Get cluster nodes
    # @return [Array] List of cluster nodes
    def get_cluster_nodes
      json_rpc('getClusterNodes')
    end

    # Get epoch information
    # Retrieves information about the current epoch in the Solana network.
    # @param options [Hash] Optional parameters.
    # @option options [String] :commitment Commitment level. Valid values are "processed", "confirmed", or "finalized" (default).
    # @option options [Integer] :min_context_slot The minimum slot at which the request should be evaluated.
    # @return [Hash] A hash containing epoch information, including:
    #   * `absoluteSlot` [Integer] The current slot.
    #   * `blockHeight` [Integer] The current block height.
    #   * `epoch` [Integer] The current epoch number.
    #   * `slotIndex` [Integer] The current slot relative to the start of the current epoch.
    #   * `slotsInEpoch` [Integer] The total number of slots in the current epoch.
    #   * `transactionCount` [Integer, nil] The total number of transactions processed in the current epoch, or null if not available.
    def get_epoch_info(options = {})
      rpc_options = options.dup
      rpc_options[:minContextSlot] = rpc_options.delete(:min_context_slot) if rpc_options.key?(:min_context_slot)
      json_rpc('getEpochInfo', [rpc_options])
    end

    # Get epoch schedule
    # @return [Hash] Epoch schedule
    def get_epoch_schedule
      json_rpc('getEpochSchedule')
    end

    # Get first available block
    # Returns the slot of the first available block in the ledger.
    # @return [Integer] The slot of the first available block.
    def get_first_available_block
      json_rpc('getFirstAvailableBlock')
    end

    # Get genesis hash
    # Returns the genesis hash of the Solana ledger.
    # @return [String] The genesis hash (base-58 encoded string).
    def get_genesis_hash
      json_rpc('getGenesisHash')
    end

    # Get health status of the node
    # Returns the health status of the node.
    # @return [String] "ok" if the node is healthy.
    # @raise [GetblockioApi::JsonRpcError] If the node is unhealthy or an error occurs.
    def get_health
      json_rpc('getHealth')
    end

    # Get identity of the node
    # Returns the identity public key of the node.
    # @return [Hash] A hash containing the node's identity public key (base-58 encoded string).
    #   * `identity` [String] The identity pubkey.
    def get_identity
      json_rpc('getIdentity')
    end

    # Get inflation governor
    # Retrieves the current inflation governor parameters for the Solana network.
    # @param options [Hash] Optional parameters.
    # @option options [String] :commitment Commitment level. Valid values are "processed", "confirmed", or "finalized" (default).
    # @return [Hash] A hash containing the inflation governor parameters, including:
    #   * `initial` [Float] The initial inflation rate.
    #   * `terminal` [Float] The terminal inflation rate.
    #   * `taper` [Float] The rate at which inflation decreases.
    #   * `foundation` [Float] The proportion of inflation allocated to the foundation.
    #   * `foundationTerm` [Float] The duration for foundation inflation allocation.
    def get_inflation_governor(options = {})
      json_rpc('getInflationGovernor', [options])
    end

    # Get inflation rate
    # Retrieves the current inflation rate details.
    # @param options [Hash] Optional parameters.
    # @option options [Integer] :epoch An epoch for which to calculate inflation. If unspecified, the current epoch is used.
    # @option options [String] :commitment Commitment level. Valid values are "processed", "confirmed", or "finalized" (default).
    # @return [Hash] A hash containing inflation rate information:
    #   * `total` [Float] Total inflation rate.
    #   * `validator` [Float] Inflation rate for validators.
    #   * `foundation` [Float] Inflation rate for the foundation.
    #   * `epoch` [Integer] The epoch for which the inflation rate was calculated.
    def get_inflation_rate(options = {})
      rpc_options = options.dup
      params = []
      params << rpc_options unless rpc_options.empty?
      json_rpc('getInflationRate', params)
    end

    # Get inflation reward
    # Retrieves the inflation reward for a list of addresses for a specific epoch.
    # @param addresses [Array<String>] An array of account addresses (base-58 encoded strings) to query.
    # @param options [Hash] Optional parameters.
    # @option options [Integer] :epoch An epoch for which to calculate inflation. If unspecified, the current epoch is used.
    # @option options [String] :commitment Commitment level. Valid values are "processed", "confirmed", or "finalized" (default).
    # @option options [Integer] :min_context_slot The minimum slot at which the request should be evaluated.
    # @return [Array<Hash, nil>] An array of reward objects, or null if reward is not found. Each reward object contains:
    #   * `epoch` [Integer] The epoch for which the reward was generated.
    #   * `effectiveSlot` [Integer] The slot in which the reward was earned.
    #   * `amount` [Integer] The reward amount in lamports.
    #   * `postBalance` [Integer] The account balance in lamports after the reward was applied.
    #   * `commission` [Integer, nil] For staking accounts, the commission taken by the validator (optional).
    def get_inflation_reward(addresses, options = {})
      rpc_options = options.dup
      rpc_options[:minContextSlot] = rpc_options.delete(:min_context_slot) if rpc_options.key?(:min_context_slot)
      params = [addresses]
      params << rpc_options unless rpc_options.empty?
      json_rpc('getInflationReward', params)
    end

    # Get highest snapshot slot
    # Retrieves the highest slot that the node has a snapshot for.
    # This is a potential indicator of the node's health and synchronization status.
    # @return [Hash] A hash containing snapshot slot information:
    #   * `full` [Integer] The highest full snapshot slot.
    #   * `incremental` [Integer, nil] The highest incremental snapshot slot, if available.
    def get_highest_snapshot_slot
      json_rpc('getHighestSnapshotSlot')
    end

    # Get leader schedule
    # Retrieves the leader schedule for the current epoch or a specific epoch.
    # @param options [Hash] Optional parameters.
    # @option options [Integer] :slot Fetch the leader schedule for the epoch that corresponds to the provided slot. If not provided, the current epoch is used.
    # @option options [String] :identity Only return results for this validator identity (base-58 encoded string).
    # @option options [String] :commitment Commitment level. Valid values are "processed", "confirmed", or "finalized" (default).
    # @return [Hash, nil] A hash where keys are validator identities and values are arrays of slot indices assigned to each leader. Returns `nil` if the schedule is not available.
    def get_leader_schedule(options = {})
      params = []
      # The RPC method expects the slot as the first parameter if provided, otherwise an options object.
      if options.key?(:slot) && options.keys.size == 1 # Only slot is provided
        params << options[:slot]
      elsif !options.empty?
        params << options
      end
      json_rpc('getLeaderSchedule', params)
    end

    # Get max retransmit slot
    # Get the max slot seen from retransmit stage.
    # @return [Integer] The max slot.
    def get_max_retransmit_slot
      json_rpc('getMaxRetransmitSlot')
    end

    # Get fee for a message.
    # Note: This method is only available in solana-core v1.9 or newer. For solana-core v1.8 and below, use the getFees method instead.
    # Calculates the transaction fee for a given Base-64 encoded message at a specific blockhash.
    # @param message [String] A Base-64 encoded transaction message.
    # @param options [Hash] Optional parameters.
    # @option options [String] :commitment Commitment level. Valid values are "processed", "confirmed", or "finalized" (default).
    # @option options [Integer] :min_context_slot The minimum slot at which the request should be evaluated.
    # @return [Hash] A hash containing the context and the fee value (in lamports) or null if the blockhash is not found or the message is invalid.
    #   The result object has a `context` and `value` field. The `value` field is an integer representing the fee in lamports, or null.
    def get_fee_for_message(message, options = {})
      rpc_options = options.dup
      rpc_options[:minContextSlot] = rpc_options.delete(:min_context_slot) if rpc_options.key?(:min_context_slot)
      params = [message]
      params << rpc_options unless rpc_options.empty?
      json_rpc('getFeeForMessage', params)
    end

    # Get minimum balance for rent exemption
    # Retrieves the minimum lamport balance required for an account to be rent exempt.
    # @param data_size [Integer] The account data size, in bytes.
    # @param options [Hash] Optional parameters.
    # @option options [String] :commitment Commitment level. Valid values are "processed", "confirmed", or "finalized" (default).
    # @return [Integer] The minimum lamport balance required.
    def get_minimum_balance_for_rent_exemption(data_size, options = {})
      params = [data_size]
      params << options unless options.empty?
      json_rpc('getMinimumBalanceForRentExemption', params)
    end

    # Get multiple accounts
    # Retrieves all metadata for a list of public keys.
    # @param pubkeys [Array<String>] An array of up to 100 public keys, as base-58 encoded strings.
    # @param options [Hash] Optional parameters.
    # @option options [String] :commitment Commitment level. Valid values are "processed", "confirmed", or "finalized" (default).
    # @option options [Integer] :min_context_slot The minimum slot at which the request should be evaluated.
    # @option options [Hash] :data_slice Specifies a portion of account data to return.
    #   * :length [Integer] Number of bytes to return.
    #   * :offset [Integer] Byte offset from which to start reading.
    # @option options [String] :encoding Encoding for account data. Valid values: "base58", "base64", "base64+zstd", "jsonParsed" (default: "base64").
    # @return [Array<Hash, nil>] An array of account information objects or nil if an account is not found.
    #   Each account object contains lamports, owner, data, executable, rentEpoch, and space.
    def get_multiple_accounts(pubkeys, options = {})
      rpc_options = options.dup
      rpc_options[:dataSlice] = rpc_options.delete(:data_slice) if rpc_options.key?(:data_slice)
      rpc_options[:minContextSlot] = rpc_options.delete(:min_context_slot) if rpc_options.key?(:min_context_slot)
      params = [pubkeys]
      params << rpc_options unless rpc_options.empty?
      json_rpc('getMultipleAccounts', params)
    end

    # Get program accounts
    # @param program_id [String] Public key of the program, as a base-58 encoded string.
    # @param options [Hash] Optional parameters.
    # @option options [String] :commitment Commitment level. Valid values are "processed", "confirmed", or "finalized" (default).
    # @option options [String] :encoding Encoding for account data. Valid values: "base58", "base64", "base64+zstd", "jsonParsed" (default: "base64").
    # @option options [Hash] :data_slice Specifies a portion of account data to return.
    #   * :length [Integer] Number of bytes to return.
    #   * :offset [Integer] Byte offset from which to start reading.
    # @option options [Array<Hash>] :filters An array of filter objects.
    #   Each filter object can be:
    #   * { memcmp: { offset: <usize>, bytes: <string> } } - Compares a provided series of bytes with program account data at a particular offset.
    #   * { dataSize: <u64> } - Compares the program account data length with the provided data size.
    # @option options [Boolean] :with_context Wraps the result in a JSON object with a `context` field.
    # @option options [Integer] :min_context_slot The minimum slot at which the request should be evaluated.
    # @return [Array<Hash>] An array of account objects, each containing pubkey and account data.
    def get_program_accounts(program_id, options = {})
      rpc_options = options.dup
      rpc_options[:dataSlice] = rpc_options.delete(:data_slice) if rpc_options.key?(:data_slice)
      rpc_options[:withContext] = rpc_options.delete(:with_context) if rpc_options.key?(:with_context)
      rpc_options[:minContextSlot] = rpc_options.delete(:min_context_slot) if rpc_options.key?(:min_context_slot)

      params = [program_id]
      params << rpc_options unless rpc_options.empty?
      json_rpc('getProgramAccounts', params)
    end

    # Get recent performance samples
    # Retrieves a list of recent performance samples from the node.
    # @param options [Hash] Optional parameters.
    # @option options [Integer] :limit The number of samples to return (default: 720, max: 720).
    # @return [Array<Hash>] An array of performance sample objects, each containing:
    #   * `slot` [Integer] Slot number for the sample.
    #   * `numTransactions` [Integer] Number of transactions processed in the slot.
    #   * `numSlots` [Integer] Number of slots in the sample period.
    #   * `samplePeriodSecs` [Integer] Sample period in seconds.
    def get_recent_performance_samples(options = {})
      params = []
      params << options[:limit] if options.key?(:limit) # RPC expects limit directly if present
      json_rpc('getRecentPerformanceSamples', params)
    end

    # Get slot
    # Retrieves the current slot the node is processing.
    # @param options [Hash] Optional parameters.
    # @option options [String] :commitment Commitment level. Valid values are "processed", "confirmed", or "finalized" (default).
    # @option options [Integer] :min_context_slot The minimum slot at which the request should be evaluated.
    # @return [Integer] The current slot.
    def get_slot(options = {})
      rpc_options = options.dup
      rpc_options[:minContextSlot] = rpc_options.delete(:min_context_slot) if rpc_options.key?(:min_context_slot)
      params = []
      params << rpc_options unless rpc_options.empty?
      json_rpc('getSlot', params)
    end

    # Get slot leader
    # Retrieves the current slot leader.
    # @param options [Hash] Optional parameters.
    # @option options [String] :commitment Commitment level. Valid values are "processed", "confirmed", or "finalized" (default).
    # @option options [Integer] :min_context_slot The minimum slot at which the request should be evaluated.
    # @return [String] The public key (base-58 encoded string) of the current slot leader.
    def get_slot_leader(options = {})
      rpc_options = options.dup
      rpc_options[:minContextSlot] = rpc_options.delete(:min_context_slot) if rpc_options.key?(:min_context_slot)
      params = []
      params << rpc_options unless rpc_options.empty?
      json_rpc('getSlotLeader', params)
    end

    # Get max shred insert slot
    # Retrieves the maximum slot to which the node has inserted shreds.
    # This is a potential indicator of the node's health and synchronization status.
    # @return [Integer] The max shred insert slot.
    def get_max_shred_insert_slot
      json_rpc('getMaxShredInsertSlot')
    end

    # Get recent prioritization fees
    # Retrieves a list of prioritization fees from recent blocks.
    # @param account_addresses [Array<String>] Optional. An array of up to 128 account addresses (base-58 encoded strings).
    #   If provided, the response reflects a fee to land a transaction locking all provided accounts as writable.
    # @return [Array<Hash>] An array of prioritization fee objects, each containing:
    #   * `slot` [Integer] Slot number.
    #   * `prioritizationFee` [Integer] The prioritization fee in micro-lamports.
    def get_recent_prioritization_fees(account_addresses = [])
      params = []
      params << account_addresses unless account_addresses.empty?
      json_rpc('getRecentPrioritizationFees', params)
    end
  end
end
