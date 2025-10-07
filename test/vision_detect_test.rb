# frozen_string_literal: true

require "test_helper"

class VisionDetectTest < Minitest::Test
  def test_detect
    stubs = {
      [:post, "/detect"] => lambda { |payload, _headers|
        assert_equal "data:image/jpeg;base64,AAA", payload[:image_url]
        assert_equal "cat", payload[:object]
        { "request_id" => "req-3", "objects" => [{ "x_min" => 0.1, "y_min" => 0.2, "x_max" => 0.3, "y_max" => 0.4 }] }
      }
    }
    client = FakeClient.new(stubs: stubs)

    result = MoondreamClient::Detect.create!(image_url: "data:image/jpeg;base64,AAA", object: "cat",
                                             client: client)
    assert_instance_of MoondreamClient::Detect, result
    assert_equal "req-3", result.request_id
    assert_equal 1, result.objects.length
    box = result.objects.first
    assert_in_delta 0.1, box.x_min
    assert_in_delta 0.2, box.y_min
  end
end
