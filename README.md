# README

## Architecture (Clean Architecture)

```
Controller → FetchService → Provider Interface → Concrete Provider
```

**Key principle:** `FetchService` depends on the `Provider` interface, never on a concrete implementation. To swap providers (e.g., WeatherAPI.com), create a new provider class - no changes to `FetchService`, controller, or views.

**No database needed** - forecasts are transient, cached in memory.

## Step 1: Project Setup

```bash
rails new weather_forecast --css=tailwind --skip-active-record -T
```

## Step 2: Add OpenWeatherMap provider and related configurations

- Implement OpenWeatherMap service for fetching weather data by ZIP code.
- Add OpenWeather API key to credentials for development and test environments.
- Include necessary gems in Gemfile and update Gemfile.lock.
- Set up VCR for API request recording and testing.
- Create tests for valid and invalid API key scenarios.
- Update .gitignore to exclude sensitive key files.

### Why OpenWeatherMap

- On a first search It thas a gem, and saves time of implementing HTTP requests as Provider
- Has a lot of free requests

## Step 3: Implement weather fetching service with response handling and caching

- Added Weather::FetchService to handle fetching weather data based on zip code and country.
- Introduced Response class for standardized success and failure responses.
- Created Weather::ForecastData to structure forecast data.
- Updated OpenWeatherMap provider to return structured forecast data.
- Added tests for Weather::FetchService and Weather::ForecastData.
-  Configured VCR for external API interactions in tests.

## Step 4: Add forecasts controller, views, and routing for weather forecast

- `app/controllers/forecasts_controller.rb`- Single `index` action
- No address param → render form only
- With address param → call `Weather::FetchService`, set `@forecast`, `@cached`, `@error`

## Running the application


### development
```
 bin/dev 
``` 

### production
```
# Build the image
docker build -t weather_forecast

# Run the container
docker run -d -p 80:80 -e OPENWEATHERMAP_API_KEY=<your open weather api_key> --name weather_forecast weather_forecast
```
