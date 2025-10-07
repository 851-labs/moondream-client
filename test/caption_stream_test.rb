# frozen_string_literal: true

require "test_helper"

class CaptionStreamTest < Minitest::Test
  def test_stream_aggregates_chunks_and_returns_caption
    {
      [:post, "/caption"] => lambda { |payload, _headers|
        # This stub should only be invoked for non-streaming create!, not stream!
        assert_equal true, payload[:stream]
        # Simulate streaming by invoking the provided on_data through FakeClient is not available,
        # so we emulate stream via Client#post_stream path only; create! is not called here.
        raise "Unexpected non-streaming call"
      }
    }

    # We need a custom client that can simulate post_stream.
    client = MoondreamClient::Client.new(MoondreamClient.configuration)

    # Monkey-patch post_stream for this test instance to yield our fake chunks.
    def client.post_stream(path, payload = {}, &block)
      raise "wrong path" unless path == "/caption"
      raise "must be streaming" unless payload[:stream]

      [{ "chunk" => "A brown " }, { "chunk" => "tabby cat" }, { "caption" => "A brown tabby cat" }].each do |evt|
        block.call(evt)
      end
    end

    received = []
    result = MoondreamClient::Caption.stream!(image_url: "data:image/jpeg;base64,AAA", length: "short",
                                              client: client) do |chunk|
      received << chunk
    end

    assert_equal ["A brown ", "tabby cat"], received
    assert_instance_of MoondreamClient::Caption, result
    assert_equal "A brown tabby cat", result.caption
  end
end
