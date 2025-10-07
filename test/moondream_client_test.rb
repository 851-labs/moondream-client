# frozen_string_literal: true

require "test_helper"

class MoondreamClientTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::MoondreamClient::VERSION
  end

  def test_configuration_defaults
    config = MoondreamClient::Configuration.new
    assert_nil config.access_token
    assert_equal MoondreamClient::Configuration::DEFAULT_URI_BASE, config.uri_base
    assert_equal MoondreamClient::Configuration::DEFAULT_REQUEST_TIMEOUT, config.request_timeout
  end
end
