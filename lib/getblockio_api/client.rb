require 'httparty'
require 'json'
require 'faye/websocket'
require 'eventmachine'
require 'thread'
require_relative 'errors'

module GetblockioApi
  # GetBlock.io API Client class
  class Client
    include HTTParty
    format :json
    headers 'Content-Type' => 'application/json'
    headers 'Accept' => 'application/json'
    
    # API types
    API_TYPE_JSON_RPC = 'json_rpc'.freeze
    API_TYPE_WEBSOCKET = 'websocket'.freeze
    API_TYPE_REST = 'rest'.freeze
    
    # Default HTTP base URI
    DEFAULT_HTTP_BASE_URI = 'https://go.getblock.io/'.freeze
    # Default WebSocket base URI
    DEFAULT_WSS_BASE_URI = 'wss://go.getblock.io/'.freeze

    # Initialize the client
    # @param api_key [String] Your GetBlock API access token
    # @param api_type [String] API type (json_rpc, websocket, rest)
    # @param base_uri [String] Base URI for GetBlock API
    # @param options [Hash] Additional configuration options (e.g.: logger, timeout, debug)
    def initialize(api_key:, api_type: API_TYPE_JSON_RPC, base_uri: nil, options: {})
      raise ArgumentError, "API key is required" if api_key.nil? || api_key.empty?
      raise ArgumentError, "Invalid API type: #{api_type}" unless [API_TYPE_JSON_RPC, API_TYPE_WEBSOCKET, API_TYPE_REST].include?(api_type)
      
      @api_key = api_key
      @api_type = api_type
      
      # Set default base URI according to API type
      default_base_uri = case api_type
                         when API_TYPE_WEBSOCKET
                           DEFAULT_WSS_BASE_URI
                         else
                           DEFAULT_HTTP_BASE_URI
                         end
      
      @base_uri = base_uri || default_base_uri
      @base_uri = @base_uri.end_with?('/') ? @base_uri : "#{@base_uri}/"
      
      @options = options
      @logger = options[:logger]
      @debug = options[:debug] || false

      self.class.base_uri(@base_uri)
      self.class.headers 'Content-Type' => 'application/json'
      self.class.default_timeout options.fetch(:timeout, 30)
      
      # If debug mode is enabled, output HTTP requests and responses
      self.class.debug_output $stdout if @debug

      # WebSocket related state (only used with WebSocket API type)
      if @api_type == API_TYPE_WEBSOCKET
        @ws = nil
        @ws_thread = nil
        @subscriptions = {}
        @pending_requests = {}
        @request_id_counter = 0
        @lock = Mutex.new
        @connected = false
        @connecting = false
        @current_wss_blockchain_path = nil
      end
    end

    # 发送 HTTP JSON-RPC 请求
    # @param blockchain_path [String] 区块链路径（如果有）
    # @param method [String] JSON-RPC 方法名
    # @param params [Array, Hash] JSON-RPC 参数
    # @return [Hash] API 响应
    def json_rpc_post(blockchain_path, method, params = [])
      raise ArgumentError, "JSON-RPC is not supported for this API type" unless @api_type == API_TYPE_JSON_RPC
      
      url_path = "#{@api_key}/#{blockchain_path}".chomp('/')
      body = build_json_rpc_payload(method, params)
      log_debug("Requesting JSON-RPC: #{self.class.base_uri}#{url_path}, Method: #{method}, Params: #{params.inspect}")
      
      if @debug
        puts "\n[DEBUG] JSON-RPC Request:"
        puts "URL: #{self.class.base_uri}#{url_path}"
        puts "Method: #{method}"
        puts "Params: #{params.inspect}"
        puts "Body: #{body}"
      end

      begin
        response = self.class.post("/#{url_path}", body: body)
        log_debug("Response JSON-RPC: Code=#{response.code}, Body=#{response.body}")
        
        if @debug
          puts "\n[DEBUG] JSON-RPC Response:"
          puts "Status: #{response.code}"
          puts "Body: #{response.body}"
        end
        
        handle_http_response(response, is_json_rpc: true)
      rescue HTTParty::Error, SocketError, Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout => e
        log_error("Network error during JSON-RPC request: #{e.message}")
        if @debug
          puts "\n[DEBUG] Network Error: #{e.class} - #{e.message}"
        end
        raise NetworkError, "Network error: #{e.message}"
      end
    end

    # 发送 REST GET 请求 (例如 Aptos)
    # @param path [String] API 路径
    # @param query [Hash] 查询参数
    # @return [Hash, Array] API 响应
    def rest_get(path, query = {})
      raise ArgumentError, "REST API is not supported for this API type" unless @api_type == API_TYPE_REST
      
      # 确保路径没有前导斜杠，防止双斜杠问题
      clean_path = path.start_with?('/') ? path[1..-1] : path
      full_path = "/#{@api_key}/#{clean_path}"
      log_debug("Requesting REST GET: #{self.class.base_uri}#{full_path}, Query: #{query}")
      
      if @debug
        puts "\n[DEBUG] REST GET Request:"
        puts "URL: #{self.class.base_uri}#{full_path}"
        puts "Query: #{query.inspect}"
      end
      
      begin
        response = self.class.get(full_path, query: query)
        log_debug("Response REST GET: Code=#{response.code}, Body=#{response.body}")
        
        if @debug
          puts "\n[DEBUG] REST GET Response:"
          puts "Status: #{response.code}"
          puts "Body: #{response.body}"
        end
        
        handle_http_response(response, is_json_rpc: false)
      rescue HTTParty::Error, SocketError, Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout => e
        log_error("Network error during REST GET request: #{e.message}")
        if @debug
          puts "\n[DEBUG] Network Error: #{e.class} - #{e.message}"
        end
        raise NetworkError, "Network error: #{e.message}"
      end
    end

    # 建立 WebSocket 连接
    def connect_wss(blockchain_path = '')
      raise ArgumentError, "WebSocket is not supported for this API type" unless @api_type == API_TYPE_WEBSOCKET
      
      return if @connected && @current_wss_blockchain_path == blockchain_path
      
      # 如果已经连接到不同的区块链，先断开连接
      disconnect_wss if @connected
      
      @connecting = true
      @current_wss_blockchain_path = blockchain_path
      
      # 构建 WebSocket URL
      wss_url = "#{@base_uri}#{@api_key}/#{blockchain_path}".chomp('/')
      log_debug("Connecting to WebSocket: #{wss_url}")
      
      if @debug
        puts "\n[DEBUG] WebSocket Connection:"
        puts "URL: #{wss_url}"
      end
      
      @ws_thread = Thread.new do
        EM.stop if EM.reactor_running?
        EM.run do
          @ws = Faye::WebSocket::Client.new(wss_url)

          @ws.on :open do |event|
            @lock.synchronize do
               @connected = true
               @connecting = false
               @current_wss_blockchain_path = target_path
            end
            log_info("WebSocket connection opened to path: '#{target_path}'.")
          end

          @ws.on :message do |event|
            log_debug("WebSocket message received: #{event.data}")
            handle_wss_message(event.data)
          end

          @ws.on :error do |event|
            log_error("WebSocket error: #{event.message}")
            @lock.synchronize do
              @connected = false
              @connecting = false
              @current_wss_blockchain_path = nil
            end
            EM.stop_event_loop if EM.reactor_running?
          end

          @ws.on :close do |event|
            log_info("WebSocket connection closed: Code=#{event.code}, Reason=#{event.reason}")
            @lock.synchronize do
              @ws = nil
              @connected = false
              @connecting = false
              @current_wss_blockchain_path = nil
              @pending_requests.each_value { |q| q.push({ error: WebSocketError.new("Connection closed") }) }
              @pending_requests.clear()
              @subscriptions.clear()
            end
            EM.stop_event_loop if EM.reactor_running?
          end
        end
      end

      # 等待连接建立或超时
      timeout = options.fetch(:wss_connect_timeout, 10)
      start_time = Time.now
      while Time.now - start_time < timeout
        @lock.synchronize do
          return true if @connected
          raise WebSocketError, "Connection failed" if !@connecting
        end
        sleep 0.1
      end

      @lock.synchronize do
        @connecting = false
      end
      raise WebSocketError, "Connection timeout after #{timeout} seconds"
    end

    # 确保 WebSocket 已连接
    def ensure_wss_connected(blockchain_path = '')
      @lock.synchronize do
        return true if @connected && @current_wss_blockchain_path == blockchain_path
      end
      connect_wss(blockchain_path)
    end

    # 发送 WebSocket 请求
    def send_wss_request(blockchain_path, method, params = [])
      ensure_wss_connected(blockchain_path)

      request_id = nil
      queue = Queue.new

      @lock.synchronize do
        request_id = @request_id_counter += 1
        @pending_requests[request_id] = queue
      end

      payload = build_json_rpc_payload(method, params, request_id)
      log_debug("Sending WebSocket request: #{payload}")

      # 发送请求
      @ws.send(payload)

      # 等待响应或超时
      timeout = options.fetch(:wss_request_timeout, 30)
      begin
        Timeout.timeout(timeout) do
          response = queue.pop
          if response[:error]
            raise response[:error]
          else
            return response[:result]
          end
        end
      rescue Timeout::Error
        @lock.synchronize do
          @pending_requests.delete(request_id)
        end
        raise WebSocketError, "Request timeout after #{timeout} seconds"
      end
    end

    # 用于取消 WebSocket 订阅
    # @param subscription_id [String] 要取消的订阅 ID
    # @return [Hash] API 响应
    def unsubscribe_by_id(blockchain_path, subscription_id)
      method = case blockchain_path.split('/').first
               when 'eth', 'bsc', 'matic', 'arb', 'opti', 'base', 'avax', 'ftm', 'gnosis', 'celo', 'algo', 'sol', 'near', 'aurora', 'tron', 'doge', 'ltc', 'bch', 'zec', 'dash', 'btc', 'ada' # 更多区块链可能需要适配不同的取消订阅方法
                 'eth_unsubscribe' # 假设通用取消订阅方法
               else
                 log_warn("Unsubscribe method for blockchain '#{blockchain_path.split('/').first}' is not explicitly defined, using 'eth_unsubscribe'.")
                 'eth_unsubscribe' # 默认
               end
      send_wss_request(blockchain_path, method, [subscription_id])
    end

    # 关闭 WebSocket 连接
    def disconnect_wss
      @lock.synchronize do
        return unless @ws && @connected
        log_info("Closing WebSocket connection...")
        @ws.close
        # 等待 WebSocket 线程结束
      end

      # 等待 EM 循环停止和线程退出
      @ws_thread&.join(options.fetch(:wss_close_timeout, 5))
      log_info("WebSocket connection closed.")
    end

    # 订阅 WebSocket 事件
    # @param blockchain_path [String] 区块链路径
    # @param method [String] 订阅方法
    # @param params [Array] 订阅参数
    # @param callback [Block] 处理订阅消息的回调
    # @return [String] 订阅 ID
    def subscribe(blockchain_path, method, params, &callback)
      raise ArgumentError, "Callback block is required for subscription" unless block_given?
      ensure_wss_connected(blockchain_path)

      response_result = send_wss_request(blockchain_path, method, params)
      subscription_id = response_result

      @lock.synchronize do
        @subscriptions[subscription_id] = callback
      end

      subscription_id
    end

    # 取消订阅
    # @param subscription_id [String] 订阅 ID
    # @return [Boolean] 是否成功取消订阅
    def unsubscribe(subscription_id)
      @lock.synchronize do
        return false unless @subscriptions.key?(subscription_id)
        @subscriptions.delete(subscription_id)
      end

      # 发送取消订阅请求
      begin
        unsubscribe_by_id(@current_wss_blockchain_path, subscription_id)
        true
      rescue => e
        log_error("Error unsubscribing: #{e.message}")
        false
      end
    end

    # 处理 WebSocket 消息
    def handle_wss_message(data)
       begin
         message = JSON.parse(data)
         request_id = message['id']
         subscription_id = message.dig('params', 'subscription')

         if request_id && @pending_requests.key?(request_id)
           # 处理请求响应
           @lock.synchronize do
             queue = @pending_requests.delete(request_id)
             if message['error']
               queue.push({ error: ApiError.new(message['error']['code'], message['error']['message']) })
             else
               queue.push({ result: message['result'] })
             end
           end
         elsif subscription_id && @subscriptions.key?(subscription_id)
           # 处理订阅消息
           callback = @subscriptions[subscription_id]
           callback.call(message['params']['result']) if callback
         else
           log_warn("Received WebSocket message with no matching request or subscription: #{data}")
         end
       rescue JSON::ParserError => e
         log_error("Failed to parse WebSocket message: #{e.message}, Data: #{data}")
       rescue => e
         log_error("Error handling WebSocket message: #{e.message}, Data: #{data}")
       end
    end

    # 构建 JSON-RPC 请求负载
    def build_json_rpc_payload(method, params, id = nil)
      payload = {
        jsonrpc: '2.0',
        method: method,
        params: params
      }
      payload[:id] = id || 'getblock.io'
      JSON.generate(payload)
    end

    # 处理 HTTP 响应
    def handle_http_response(response, is_json_rpc: true)
      if @debug
        puts "\n[DEBUG] Processing HTTP Response:"
        puts "Status Code: #{response.code}"
        puts "Is JSON-RPC: #{is_json_rpc}"
      end
      
      case response.code
      when 200
        if is_json_rpc
          begin
            body = JSON.parse(response.body)
            if @debug
              puts "[DEBUG] Parsed JSON body: #{body.inspect}"
            end
            
            if body['error']
              error = body['error']
              if @debug
                puts "[DEBUG] JSON-RPC Error: code=#{error['code']}, message=#{error['message']}"
              end
              raise ApiError.new(error['code'], error['message'], error['data'])
            else
              body['result']
            end
          rescue JSON::ParserError => e
            if @debug
              puts "[DEBUG] JSON Parse Error: #{e.message}"
              puts "[DEBUG] Raw response body: #{response.body}"
            end
            raise ApiError.new(0, "Invalid JSON response: #{e.message}")
          end
        else
          begin
            JSON.parse(response.body)
          rescue JSON::ParserError => e
            if @debug
              puts "[DEBUG] JSON Parse Error: #{e.message}"
              puts "[DEBUG] Raw response body: #{response.body}"
            end
            raise ApiError.new(0, "Invalid JSON response: #{e.message}")
          end
        end
      when 401, 403
        if @debug
          puts "[DEBUG] Authentication Error: #{response.body}"
        end
        raise AuthenticationError, "Authentication failed: #{response.body}"
      when 404
        if @debug
          puts "[DEBUG] Not Found Error: #{response.body}"
        end
        raise ApiError.new(404, "Not found: #{response.body}")
      when 405
        if @debug
          puts "[DEBUG] Method Not Allowed Error: #{response.body}"
        end
        raise MethodNotAllowedError.new(response.body)
      when 429
        if @debug
          puts "[DEBUG] Rate Limit Error: #{response.body}"
        end
        raise ApiError.new(429, "Rate limit exceeded: #{response.body}")
      when 500..599
        if @debug
          puts "[DEBUG] Server Error: #{response.body}"
        end
        raise ApiError.new(response.code, "Server error: #{response.body}")
      else
        if @debug
          puts "[DEBUG] Unexpected Response: #{response.body}"
        end
        raise ApiError.new(response.code, "Unexpected response: #{response.body}")
      end
    end

    # 日志方法
    def log_debug(message)
      @logger&.debug(message)
    end

    def log_info(message)
      @logger&.info(message)
    end

    def log_warn(message)
      @logger&.warn(message)
    end

    def log_error(message)
      @logger&.error(message)
    end
  end
end
