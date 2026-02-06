module Weather
  class FetchService
    CACHE_TTL = 30.minutes

    def initialize(zip_code:, country:, provider: Weather::Providers::OpenWeatherMap)
      @zip_code = zip_code
      @country = country
      @provider = provider.new
    end

    def call
      return missing_zip_error unless zip_code

      cached = true
      data = forecast_data(cached)

      Response.success(data:, meta: { cached:, zip_code: })
    rescue StandardError => e
      Rails.logger.error("Weather::FetchService Error: #{e.message}")
      Response.failure(errors: [ "Weather service failed" ])
    end

    private

    attr_reader :zip_code, :provider, :country

    def missing_zip_error
      Response.failure(errors: [ "Could not find a zip code in the address provided." ])
    end

    def forecast_data(cached)
      Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
        cached = false
        provider.fetch_weather_from_zip(zip: zip_code, country: country)
      end
    end

    def cache_key
      "forecast_#{zip_code}_#{country}"
    end
  end
end
