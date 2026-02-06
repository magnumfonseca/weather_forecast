class ForecastsController < ApplicationController
  def index
    return unless params[:zip_code].present?
    return unless params[:country].present?

    response = fetch_weather
    response.success? ? handle_success(response) : handle_failure(response)
  end

  private

  def zip_code
    params[:zip_code]
  end

  def country
    params[:country]&.match(/\A[A-Z]{2}\z/i)&.to_s
  end

  def fetch_weather
    Weather::FetchService.new(zip_code:, country:).call
  end

  def handle_success(response)
    @forecast = response.data
    @cached = response.meta[:cached]
  end

  def handle_failure(response)
    @error = response.errors.first
  end
end
