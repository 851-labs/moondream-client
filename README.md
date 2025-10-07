# MoondreamClient

Ruby client for the Moondream API, providing typed classes for Caption, Query, Detect, and Point, plus streaming captions.

## Installation

Install the gem and add to the application"s Gemfile by executing:

    $ bundle add moondream-client

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install moondream-client

## Usage

### Configuration

Configure the client once at boot (e.g., in Rails an initializer) using `MoondreamClient.configure`.

Get an access token from the Moondream Cloud: https://moondream.ai/c/cloud/api-keys.

```ruby
MoondreamClient.configure do |config|
  config.access_token = ENV["MOONDREAM_ACCESS_TOKEN"]
  config.uri_base = "https://api.moondream.ai/v1" # Optional (default: https://api.moondream.ai/v1)
  config.request_timeout = 120 # Optional (default: 120)
end
```

### Caption

Create captions via the `/caption` endpoint. If you pass an `http(s)` image URL, the client will download it and convert it to a base64 data URL automatically.

```ruby
caption = MoondreamClient::Caption.create!(
  image_url: "data:image/jpeg;base64,..." # or https URL,
  length: "short" # or "normal",
  stream: false
)
caption.caption       # => String caption text
caption.request_id    # => String request id
```

#### Streaming captions

You can stream caption chunks and get a final `Caption` object at the end:

```ruby
final = MoondreamClient::Caption.stream!(
  image_url: "data:image/jpeg;base64,...", # or https URL
  length: "short"
) do |chunk|
  print chunk # chunk is a String
end

final.caption # => String final caption
```

### Query

Ask questions about an image via `/query`. `http(s)` URLs are automatically converted to base64 data URLs.

```ruby
query = MoondreamClient::Query.create!(
  image_url: "data:image/jpeg;base64,...",
  question: "What color is the car?"
)
query.answer          # => String answer text
query.request_id      # => String request id
```

### Detect

Detect objects and return bounding boxes via `/detect`. `http(s)` URLs are automatically converted to base64 data URLs.

```ruby
detect = MoondreamClient::Detect.create!(
  image_url: "data:image/jpeg;base64,...",
  object: "person"
)
detect.objects        # => [#<BoundingBox x_min y_min x_max y_max>]
detect.request_id     # => String request id
```

### Point

Locate center points for objects via `/point`. `http(s)` URLs are automatically converted to base64 data URLs.

```ruby
point = MoondreamClient::Point.create!(
  image_url: "data:image/jpeg;base64,...",
  object: "face"
)
point.points          # => [#<Coordinate x y>]
point.request_id      # => String request id
```

### Error handling

HTTP and API errors raise typed exceptions:

- `MoondreamClient::UnauthorizedError` (401)
- `MoondreamClient::ForbiddenError` (403)
- `MoondreamClient::NotFoundError` (404)
- `MoondreamClient::ServerError` (other non-success)

Rescue them as needed:

```ruby
begin
  MoondreamClient::Caption.create!(
    image_url: "data:image/jpeg;base64,...",
    length: "short"
  )
rescue MoondreamClient::UnauthorizedError
  # handle invalid/missing token
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to rubygems.org.

For local development, copy the example environment file and set your API token so `bin/console` can load it automatically:

```
cp .env.example .env
echo 'MOONDREAM_ACCESS_TOKEN=your_api_token_here' >> .env
```
