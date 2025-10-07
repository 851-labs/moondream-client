# frozen_string_literal: true

module MoondreamClient
  class Query
    # @return [String] The server-generated request identifier.
    attr_reader :request_id

    # @return [String] The model's answer text.
    attr_reader :answer

    # Initialize a new Query result object.
    #
    # @param attributes [Hash] Raw attributes from the /query endpoint response.
    # @param client [MoondreamClient::Client]
    def initialize(attributes, client: MoondreamClient.client)
      @client = client
      reset_attributes(attributes)
    end

    class << self
      # Ask a question about an image.
      # Corresponds to POST /query
      #
      # @param image_url [String]
      # @param question [String]
      # @param client [MoondreamClient::Client]
      #
      # @return [MoondreamClient::Query]
      def create!(image_url:, question:, client: MoondreamClient.client)
        image_data_url = MoondreamClient::Image.to_data_url(image_url)
        payload = {
          image_url: image_data_url,
          question: question
        }

        attributes = client.post("/query", payload)
        new(attributes, client: client)
      end
    end

    private

    # Normalize attributes from the /query response.
    # @param attributes [Hash]
    # @return [void]
    def reset_attributes(attributes)
      @request_id = attributes["request_id"]
      @answer = attributes["answer"]
    end
  end
end
