# frozen_string_literal: true

module MoondreamClient
  class Detect
    class BoundingBox
      # @return [Float] Normalized minimum x coordinate (0.0..1.0)
      attr_reader :x_min
      # @return [Float] Normalized minimum y coordinate (0.0..1.0)
      attr_reader :y_min
      # @return [Float] Normalized maximum x coordinate (0.0..1.0)
      attr_reader :x_max
      # @return [Float] Normalized maximum y coordinate (0.0..1.0)
      attr_reader :y_max

      def initialize(x_min:, y_min:, x_max:, y_max:)
        @x_min = x_min
        @y_min = y_min
        @x_max = x_max
        @y_max = y_max
      end
    end

    # @return [String] The server-generated request identifier.
    attr_reader :request_id

    # @return [Array<BoundingBox>] The list of detected object bounding boxes.
    attr_reader :objects

    # Initialize a new Detect result object.
    #
    # @param attributes [Hash] Raw attributes from the /detect endpoint response.
    # @param client [MoondreamClient::Client]
    def initialize(attributes, client: MoondreamClient.client)
      @client = client
      reset_attributes(attributes)
    end

    class << self
      # Detect objects described by `object` within an image.
      # Corresponds to POST /detect
      #
      # @param image_url [String]
      # @param object [String] Object description, e.g. "person".
      # @param client [MoondreamClient::Client]
      #
      # @return [MoondreamClient::Detect]
      def create!(image_url:, object:, client: MoondreamClient.client)
        image_data_url = MoondreamClient::Image.to_data_url(image_url)
        payload = {
          image_url: image_data_url,
          object: object
        }

        attributes = client.post("/detect", payload)
        new(attributes, client: client)
      end
    end

    private

    # Normalize attributes from the /detect response.
    # @param attributes [Hash]
    # @return [void]
    def reset_attributes(attributes)
      @request_id = attributes["request_id"]
      @objects = Array(attributes["objects"]).map do |o|
        BoundingBox.new(x_min: o["x_min"], y_min: o["y_min"], x_max: o["x_max"], y_max: o["y_max"])
      end
    end
  end
end
