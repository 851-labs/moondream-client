# frozen_string_literal: true

module MoondreamClient
  class Client
    # The configuration for the client.
    #
    # @return [MoondreamClient::Configuration]
    attr_accessor :configuration

    # Initialize the client.
    #
    # @param configuration [MoondreamClient::Configuration] The configuration for the client.
    #
    # @return [MoondreamClient::Client]
    def initialize(configuration = MoondreamClient.configuration)
      @configuration = configuration
    end

    # Make a POST request to the API.
    #
    # @param path [String] The path to the API endpoint.
    # @param payload [Hash] The payload to send to the API.
    # @param headers [Hash] The headers to send to the API.
    #
    # @return [Hash] The response from the API.
    def post(path, payload, headers: {})
      response = connection.post(build_url(path)) do |request|
        request.headers["X-Moondream-Auth"] = @configuration.access_token if @configuration.access_token
        request.headers["Content-Type"] = "application/json"
        request.headers["Accept"] = "application/json"
        request.headers.merge!(headers)
        request.body = payload.compact.to_json
      end

      handle_error(response) unless response.success?

      JSON.parse(response.body)
    end

    # Make a GET request to the API.
    #
    # @param path [String] The path to the API endpoint.
    #
    # @return [Hash] The response from the API.
    def get(path)
      response = connection.get(build_url(path)) do |request|
        request.headers["X-Moondream-Auth"] = @configuration.access_token if @configuration.access_token
        request.headers["Content-Type"] = "application/json"
      end

      handle_error(response) unless response.success?

      JSON.parse(response.body)
    end

    # Make a streaming POST request to the API using text/event-stream.
    # Parses SSE lines and yields decoded event data Hashes to the provided block.
    #
    # @param path [String]
    # @param payload [Hash]
    # @param headers [Hash]
    # @yield [data] yields parsed JSON from each SSE event's data field
    # @return [void]
    def post_stream(path, payload = {}, headers: {}, &block)
      decoder = SSEDecoder.new
      buffer = ""

      connection.post(build_url(path)) do |request|
        request.headers["X-Moondream-Auth"] = @configuration.access_token if @configuration.access_token
        request.headers["Accept"] = "text/event-stream"
        request.headers["Cache-Control"] = "no-store"
        request.headers["Content-Type"] = "application/json"
        request.headers.merge!(headers)
        request.body = payload.compact.to_json
        request.options.on_data = lambda { |chunk, _total_bytes, _env|
          # Normalize and split into lines, preserving last partial line in buffer
          buffer = (buffer + chunk.to_s).gsub(/\r\n?/, "\n")
          lines = buffer.split("\n", -1)
          buffer = lines.pop || ""
          lines.each do |line|
            event = decoder.decode(line)
            block&.call(event["data"]) if event && event["data"]
          end
        }
      end
    end

    # Handle errors from the API.
    #
    # @param response [Faraday::Response] The response from the API.
    #
    # @return [void]
    def handle_error(response)
      case response.status
      when 401
        raise UnauthorizedError, response.body
      when 403
        raise ForbiddenError, response.body
      when 404
        raise NotFoundError, response.body
      else
        raise ServerError, response.body
      end
    end

    private

    # Minimal SSE decoder for parsing standard server-sent event lines.
    class SSEDecoder
      def initialize
        @event = ""
        @data = ""
        @id = nil
        @retry = nil
      end

      # @param line [String]
      # @return [Hash, nil]
      def decode(line)
        return flush_event if line.empty?
        return if line.start_with?(":")

        field, _, value = line.partition(":")
        value = value.lstrip

        case field
        when "event"
          @event = value
        when "data"
          @data += "#{value}\n"
        when "id"
          @id = value
        when "retry"
          @retry = value.to_i
        end

        nil
      end

      private

      def flush_event
        return if @data.empty?

        data = @data.chomp
        parsed = JSON.parse(data)

        event = { "data" => parsed }
        event["event"] = @event unless @event.empty?
        event["id"] = @id if @id
        event["retry"] = @retry if @retry

        @event = ""
        @data = ""
        @id = nil
        @retry = nil

        event
      end
    end

    # Build the URL for the API.
    #
    # @param path [String] The path to the API endpoint.
    def build_url(path)
      "#{@configuration.uri_base}#{path}"
    end

    # Create a connection to the API.
    #
    # @return [Faraday::Connection]
    def connection
      Faraday.new do |faraday|
        faraday.request :url_encoded
        faraday.options.timeout = @configuration.request_timeout
        faraday.options.open_timeout = @configuration.request_timeout
      end
    end
  end
end
