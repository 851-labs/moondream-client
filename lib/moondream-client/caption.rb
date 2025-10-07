# frozen_string_literal: true

module MoondreamClient
  class Caption
    # @return [String] The server-generated request identifier.
    attr_reader :request_id

    # @return [String] The generated caption text.
    attr_reader :caption

    # Initialize a new Caption result object.
    #
    # @param attributes [Hash] Raw attributes from the /caption endpoint response.
    # @param client [MoondreamClient::Client]
    def initialize(attributes, client: MoondreamClient.client)
      @client = client
      reset_attributes(attributes)
    end

    class << self
      # Create a caption for an image.
      # Corresponds to POST /caption
      #
      # @param image_url [String] A URL or data URL for the image.
      # @param length [String] "short" or "normal" (default).
      # @param stream [Boolean] Whether to stream the response (default: false).
      # @param client [MoondreamClient::Client]
      #
      # @return [MoondreamClient::Caption]
      def create!(image_url:, length: "normal", stream: false, client: MoondreamClient.client)
        image_data_url = MoondreamClient::Image.to_data_url(image_url)
        payload = {
          image_url: image_data_url,
          length: length,
          stream: stream
        }

        attributes = client.post("/caption", payload)
        new(attributes, client: client)
      end

      # Stream caption chunks and return the final Caption instance.
      #
      # @param image_url [String]
      # @param length [String]
      # @param client [MoondreamClient::Client]
      # @yield [chunk] yields each text chunk String as it arrives
      # @return [MoondreamClient::Caption]
      def stream!(image_url:, length: "normal", client: MoondreamClient.client, &block)
        image_data_url = MoondreamClient::Image.to_data_url(image_url)
        payload = {
          image_url: image_data_url,
          length: length,
          stream: true
        }

        caption = nil

        client.post_stream("/caption", payload) do |data|
          if (chunk = data["chunk"]) && !chunk.to_s.empty?
            block&.call(chunk)
          end

          caption = data["caption"] if data["caption"]
        end

        # Build the final Caption from aggregated stream content.
        new({ "caption" => caption }, client: client)
      end
    end

    private

    # Normalize attributes from the /caption response.
    # @param attributes [Hash]
    # @return [void]
    def reset_attributes(attributes)
      @request_id = attributes["request_id"]
      @caption = attributes["caption"]
    end
  end
end
