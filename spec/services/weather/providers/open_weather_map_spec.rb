require "rails_helper"

RSpec.describe Weather::Providers::OpenWeatherMap do
  describe "#fetch_weather_from_zip", :vcr do
    subject(:service) { described_class.new(api_key:) }

    context "when api_key is valid" do
      let(:api_key) { Rails.application.credentials.dig(:open_weather_map, :api_key) }

      it "returns the weather data" do
        response = service.fetch_weather_from_zip(zip: 10018)

        expect(response).to be_a(Weather::ForecastData)
        expect(response.current.city).to eq("New York")
      end
    end

    context "when api_key is invalid" do
      let(:api_key) { "invalid_api_key" }

      it "raises error" do
        expect { service.fetch_weather_from_zip(zip: 10018) }
          .to raise_error(OpenWeather::Errors::Fault)
      end
    end
  end
end
