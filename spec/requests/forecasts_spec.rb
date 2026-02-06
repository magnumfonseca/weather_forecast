require "rails_helper"

RSpec.describe "Forecasts", type: :request do
  before { Rails.cache.clear }

  describe "GET /" do
    context "without params" do
      it "renders the form" do
        get root_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Get Forecast")
      end

      it "does not render forecast data" do
        get root_path

        expect(response.body).not_to include("forecast-data")
        expect(response.body).not_to include("forecast-error")
      end
    end

    context "with valid zip code and country", :vcr do
      it "renders forecast data" do
        get root_path, params: { zip_code: "10018", country: "US" }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("forecast-data")
        expect(response.body).to include("New York")
      end
    end

    context "with non-US zip code", :vcr do
      it "renders forecast data for the given country" do
        get root_path, params: { zip_code: "10115", country: "DE" }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("forecast-data")
        expect(response.body).to include("Berlin")
      end
    end

    context "with missing zip code" do
      it "renders an error" do
        get root_path, params: { zip_code: "", country: "US" }

        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include("forecast-data")
      end
    end

    context "with invalid country format" do
      it "renders the form without forecast data" do
        get root_path, params: { zip_code: "10018", country: "INVALID" }

        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include("forecast-data")
      end
    end

    context "when provider raises an error" do
      before do
        allow_any_instance_of(Weather::Providers::OpenWeatherMap)
          .to receive(:fetch_weather_from_zip).and_raise(StandardError, "API error")
      end

      it "renders an error message" do
        get root_path, params: { zip_code: "10018", country: "US" }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("forecast-error")
      end
    end
  end
end
