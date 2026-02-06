require "rails_helper"

RSpec.describe Weather::ForecastData do
    describe Weather::ForecastData::CurrentWeather do
      subject(:current) do
        described_class.new(
          temperature_f: 30.25,
          high_f: 30.42,
          low_f: 24.82,
          description: "clear sky",
          icon: "01n",
          city: "New York",
          humidity: 43,
          wind_speed: 4.61
        )
      end

      it "converts temperature to celsius" do
        expect(current.temperature_c).to eq(-1.0)
      end

      it "converts high to celsius" do
        expect(current.high_c).to eq(-0.9)
      end

      it "converts low to celsius" do
        expect(current.low_c).to eq(-4.0)
      end

      it "is immutable" do
        expect { current.instance_variable_set(:@temperature_f, 100) }
          .to raise_error(FrozenError)
      end

      it "has value equality" do
        same = described_class.new(
          temperature_f: 30.25, high_f: 30.42, low_f: 24.82,
          description: "clear sky", icon: "01n", city: "New York",
          humidity: 43, wind_speed: 4.61
        )

        expect(current).to eq(same)
      end
    end
  end
