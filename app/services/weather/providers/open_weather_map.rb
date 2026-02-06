module Weather
  module Providers
    class OpenWeatherMap
      API_KEY = ENV["OPENWEATHERMAP_API_KEY"] || Rails.application.credentials.dig(:open_weather_map, :api_key)

      def initialize(api_key: API_KEY, units: "imperial")
        @api_key = api_key
        @units = units
        @provider = OpenWeather::Client.new(api_key:)
      end

      def fetch_weather_from_zip(zip:, country: "US")
        provider.current_weather(zip:, country:, units:)
      end

      private

      attr_reader :api_key, :provider, :units
    end
  end
end
