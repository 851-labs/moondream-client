# frozen_string_literal: true

require "test_helper"

class VisionQueryTest < Minitest::Test
  def test_query
    stubs = {
      [:post, "/query"] => lambda { |payload, _headers|
        assert_equal "data:image/jpeg;base64,AAA", payload[:image_url]
        assert_equal "What color is the car?", payload[:question]
        { "request_id" => "req-2", "answer" => "The car is red." }
      }
    }
    client = FakeClient.new(stubs: stubs)

    result = MoondreamClient::Query.create!(image_url: "data:image/jpeg;base64,AAA",
                                            question: "What color is the car?", client: client)
    assert_instance_of MoondreamClient::Query, result
    assert_equal "req-2", result.request_id
    assert_match(/red/i, result.answer)
  end
end
