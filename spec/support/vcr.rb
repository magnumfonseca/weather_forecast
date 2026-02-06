require "vcr"
require "webmock/rspec"

VCR.configure do |c|
  c.cassette_library_dir = Rails.root.join("spec", "vcr_cassettes")
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = false
  c.default_cassette_options = { record: :once }

  # Filter the OpenWeather API key from recorded cassettes
  c.filter_sensitive_data('<OPENWEATHER_API_KEY>') do
    ENV['OPENWEATHERMAP_API_KEY'] || Rails.application.credentials.dig(:open_weather_map, :api_key)
  end

  # Scrub API key from request URIs when recording
  c.before_record do |interaction|
    if interaction.request.uri
      interaction.request.uri = interaction.request.uri&.gsub!(/appid=[^&\s]+/, 'appid=<OPENWEATHER_API_KEY>')
    end
    if interaction.request.body
      interaction.request.body = interaction.request.body&.gsub!(/appid=[^&\s]+/, 'appid=<OPENWEATHER_API_KEY>')
    end
    if interaction.response && interaction.response.body
      interaction.response.body = interaction.response.body&.gsub!(/appid=[^&\s]+/, 'appid=<OPENWEATHER_API_KEY>')
    end
  end
end
