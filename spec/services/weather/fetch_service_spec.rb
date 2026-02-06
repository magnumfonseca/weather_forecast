require "rails_helper"

RSpec.describe Weather::FetchService do
  describe "#call" do
    subject(:service) { described_class.new(zip_code:, country:) }

    let(:country) { "US" }

    before { Rails.cache.clear }

    context "when zip_code is valid", :vcr do
      let(:zip_code) { 10018 }

      it "returns a successful response with forecast data" do
        response = service.call

        expect(response).to be_success
        expect(response.data).to be_a(Weather::ForecastData)
        expect(response.data.current.city).to eq("New York")
        expect(response.meta[:zip_code]).to eq(10018)
      end
    end

    context "when zip_code is nil" do
      let(:zip_code) { nil }

      it "returns a failure response" do
        response = service.call

        expect(response).to be_failure
      end
    end

    context "when provider raises an error", :vcr do
      subject(:service) do
        described_class.new(zip_code:, country:, provider: invalid_provider)
      end

      let(:zip_code) { 10018 }
      let(:invalid_provider) do
        Class.new(Weather::Providers::OpenWeatherMap) do
          def initialize
            super(api_key: "invalid_api_key")
          end
        end
      end

      it "returns a failure response" do
        response = service.call

        expect(response).to be_failure
      end
    end

    context "when result is cached" do
      let(:zip_code) { 10018 }
      let(:provider_class) { class_double(Weather::Providers::OpenWeatherMap) }
      let(:provider_instance) { instance_double(Weather::Providers::OpenWeatherMap) }
      let(:forecast_data) do
        Weather::ForecastData.new(
          current: Weather::ForecastData::CurrentWeather.new(
            temperature_f: 72.0, high_f: 75.0, low_f: 65.0,
            description: "clear sky", icon: "http://example.com/icon.png",
            city: "New York", humidity: 50, wind_speed: 5.0
          )
        )
      end

      around do |example|
        original_cache = Rails.cache
        Rails.cache = ActiveSupport::Cache::MemoryStore.new
        example.run
      ensure
        Rails.cache = original_cache
      end

      before do
        allow(provider_class).to receive(:new).and_return(provider_instance)
        allow(provider_instance).to receive(:fetch_weather_from_zip).and_return(forecast_data)
      end

      it "does not call the provider on subsequent requests" do
        service = described_class.new(zip_code:, country:, provider: provider_class)

        service.call
        service.call

        expect(provider_instance).to have_received(:fetch_weather_from_zip).once
      end
    end

    context "non-US zip code", :vcr do
      let(:zip_code) { "10115" }
      let(:country) { "DE" }

      it "returns a successful response with forecast data" do
        response = service.call

        expect(response).to be_success
        expect(response.data).to be_a(Weather::ForecastData)
        expect(response.data.current.city).to eq("Berlin")
        expect(response.meta[:zip_code]).to eq("10115")
      end
    end
  end
end
