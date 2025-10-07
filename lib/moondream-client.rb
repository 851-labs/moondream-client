# frozen_string_literal: true

require "faraday"
require "time"

require_relative "moondream-client/version"
require_relative "moondream-client/client"
require_relative "moondream-client/image"
require_relative "moondream-client/caption"
require_relative "moondream-client/detect"
require_relative "moondream-client/point"
require_relative "moondream-client/query"

module MoondreamClient
  class Error < StandardError; end
  class UnauthorizedError < Error; end
  class NotFoundError < Error; end
  class ServerError < Error; end
  class ConfigurationError < Error; end
  class ForbiddenError < Error; end

  class Configuration
    DEFAULT_URI_BASE = "https://api.moondream.ai/v1"
    DEFAULT_REQUEST_TIMEOUT = 120

    # The access token for the API.
    #
    # @return [String]
    attr_accessor :access_token

    # The base URI for the API.
    #
    # @return [String]
    attr_accessor :uri_base

    # The request timeout in seconds.
    #
    # @return [Integer]
    attr_accessor :request_timeout

    def initialize
      @access_token = ENV.fetch("MOONDREAM_ACCESS_TOKEN", nil)
      @uri_base = DEFAULT_URI_BASE
      @request_timeout = DEFAULT_REQUEST_TIMEOUT
    end
  end

  class << self
    # The configuration for the client.
    #
    # @return [MoondreamClient::Configuration]
    def configuration
      @configuration ||= Configuration.new
    end

    # Allows replacing the configuration object.
    attr_writer :configuration

    # Configure the client.
    #
    # @yield [MoondreamClient::Configuration] The configuration for the client.
    def configure
      yield(configuration)
    end

    # The client for the API.
    #
    # @return [MoondreamClient::Client]
    def client
      @client ||= Client.new(configuration)
    end
  end
end
