# frozen_string_literal: true

module MoondreamClient
  class Point
    class Coordinate
      # @return [Float] Normalized x coordinate (0.0..1.0)
      attr_reader :x
      # @return [Float] Normalized y coordinate (0.0..1.0)
      attr_reader :y

      def initialize(x:, y:) # rubocop:disable Naming/MethodParameterName
        @x = x
        @y = y
      end
    end

    # @return [String] The server-generated request identifier.
    attr_reader :request_id

    # @return [Array<Coordinate>] The list of point coordinates.
    attr_reader :points

    # Initialize a new Point result object.
    #
    # @param attributes [Hash] Raw attributes from the /point endpoint response.
    # @param client [MoondreamClient::Client]
    def initialize(attributes, client: MoondreamClient.client)
      @client = client
      reset_attributes(attributes)
    end

    class << self
      # Locate the center points for objects described by `object` in an image.
      # Corresponds to POST /point
      #
      # @param image_url [String]
      # @param object [String] Object description, e.g. "face".
      # @param client [MoondreamClient::Client]
      #
      # @return [MoondreamClient::Point]
      def create!(image_url:, object:, client: MoondreamClient.client)
        image_data_url = MoondreamClient::Image.to_data_url(image_url)
        payload = {
          image_url: image_data_url,
          object: object
        }

        attributes = client.post("/point", payload)
        new(attributes, client: client)
      end
    end

    private

    # Normalize attributes from the /point response.
    # @param attributes [Hash]
    # @return [void]
    def reset_attributes(attributes)
      @request_id = attributes["request_id"]
      @points = Array(attributes["points"]).map do |p|
        Coordinate.new(x: p["x"], y: p["y"])
      end
    end
  end
end
