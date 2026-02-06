module Weather
  module Providers
    class OpenWeatherMap
      API_KEY = ENV["OPENWEATHERMAP_API_KEY"] || Rails.application.credentials.dig(:open_weather_map, :api_key)

      def initialize(api_key: API_KEY, units: "imperial")
        @api_key = api_key
        @units = units
        @provider = OpenWeather::Client.new(api_key:, timeout: 5, open_timeout: 3)
      end

      def fetch_weather_from_zip(zip:, country: "US")
        response = provider.current_weather(zip:, country:, units:)
        forecast_data(response)
      end

      private

      attr_reader :api_key, :provider, :units

      def forecast_data(response)
        Weather::ForecastData.new(
          current: Weather::ForecastData::CurrentWeather.new(
            temperature_f: response.main.temp,
            high_f: response.main.temp_max,
            low_f: response.main.temp_min,
            description: response.weather.first.description,
            icon: response.weather.first.icon_uri,
            city: response.name,
            humidity: response.main.humidity,
            wind_speed: response.wind.speed
          )
        )
      end
    end
  end
end
