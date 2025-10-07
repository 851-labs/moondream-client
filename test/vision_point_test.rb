# frozen_string_literal: true

require "test_helper"

class VisionPointTest < Minitest::Test
  def test_point
    stubs = {
      [:post, "/point"] => lambda { |payload, _headers|
        assert_equal "data:image/jpeg;base64,AAA", payload[:image_url]
        assert_equal "nose", payload[:object]
        { "request_id" => "req-4", "points" => [{ "x" => 0.12, "y" => 0.34 }] }
      }
    }
    client = FakeClient.new(stubs: stubs)

    result = MoondreamClient::Point.create!(image_url: "data:image/jpeg;base64,AAA", object: "nose",
                                            client: client)
    assert_instance_of MoondreamClient::Point, result
    assert_equal "req-4", result.request_id
    assert_equal 1, result.points.length
    point = result.points.first
    assert_in_delta 0.12, point.x
    assert_in_delta 0.34, point.y
  end
end
