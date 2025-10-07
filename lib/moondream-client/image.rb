# frozen_string_literal: true

require "base64"

module MoondreamClient
  module Image
    class << self
      # Convert an input reference into a data URL.
      # If it is already a data URL, return as-is.
      # If it is an HTTP(S) URL, download and convert to base64 data URL.
      # Otherwise, return as-is.
      #
      # @param reference [String]
      # @return [String]
      def to_data_url(reference)
        return reference if data_url?(reference)

        return http_to_data_url(reference) if http_url?(reference)

        reference
      end

      private

      def data_url?(value)
        value.is_a?(String) && value.start_with?("data:")
      end

      def http_url?(value)
        value.is_a?(String) && (value.start_with?("http://") || value.start_with?("https://"))
      end

      def http_to_data_url(url)
        connection = Faraday.new do |faraday|
          faraday.request :url_encoded
          faraday.options.timeout = MoondreamClient.configuration.request_timeout
          faraday.options.open_timeout = MoondreamClient.configuration.request_timeout
        end

        response = connection.get(url)
        raise MoondreamClient::ServerError, "Failed to download image: #{response.status}" unless response.success?

        content_type = response.headers["content-type"] || "image/jpeg"
        base64 = Base64.strict_encode64(response.body)
        "data:#{content_type};base64,#{base64}"
      end
    end
  end
end
