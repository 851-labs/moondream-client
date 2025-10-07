# frozen_string_literal: true

require "test_helper"

class VisionCaptionTest < Minitest::Test
  def test_generate_caption
    stubs = {
      [:post, "/caption"] => lambda { |payload, _headers|
        assert_equal "data:image/jpeg;base64,AAA", payload[:image_url]
        assert_equal "short", payload[:length]
        assert_equal false, payload[:stream]
        { "request_id" => "req-1", "caption" => "A person on a beach" }
      }
    }
    client = FakeClient.new(stubs: stubs)

    result = MoondreamClient::Caption.create!(image_url: "data:image/jpeg;base64,AAA", length: "short",
                                              client: client)
    assert_instance_of MoondreamClient::Caption, result
    assert_equal "req-1", result.request_id
    assert_equal "A person on a beach", result.caption
  end
end
