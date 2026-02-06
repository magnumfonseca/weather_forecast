module Weather
  class ForecastData
    CurrentWeather = Data.define(
      :temperature_f, :high_f, :low_f,
      :description, :icon, :city, :humidity, :wind_speed
    ) do
        def temperature_c = fahrenheit_to_celsius(temperature_f)
        def high_c = fahrenheit_to_celsius(high_f)
        def low_c = fahrenheit_to_celsius(low_f)

      private

      def fahrenheit_to_celsius(f)
        ((f - 32) * 5.0 / 9).round(1)
      end
    end

    attr_reader :current

    def initialize(current:)
      @current = current
    end
  end
end
