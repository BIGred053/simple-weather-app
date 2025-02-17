require 'rails_helper'

RSpec.describe WeatherSources::NWS::WeatherClient do
  describe "#get_current_weather" do
    subject { described_class.new(faraday_connection).get_current_weather(lat, long) }
    let(:lat) { 39.9023 }
    let(:long) { -81.4224 }
    let(:connection_stub) { Faraday::Adapter::Test::Stubs.new }
    let(:faraday_connection) do
      Faraday.new(described_class::NWS_API_BASE_URL) { |conn| conn.adapter(:test, connection_stub) }
    end
    let(:latest_weather_hash) { { properties: { temperature: { unitCode: "wmoUnit:degC", value: 0.0 } } } }
    let(:stubbed_points_get) do
      connection_stub.get("points/#{lat},#{long}") do
        [
          200,
          { "Content-Type" => "application/json" },
          { properties: { gridId: "OFFICE", gridX: 0, gridY: 0 } }.to_json
        ]
      end
    end
    let(:stubbed_stations_get) do
      connection_stub.get("gridpoints/OFFICE/0,0/stations") do
        [
          200,
          { "Content-Type" => "application/json" },
          { features: [ properties: { stationIdentifier: "STAT" } ] }.to_json
        ]
      end
    end
    let(:stubbed_latest_weather_get) do
      connection_stub.get("stations/STAT/observations/latest") do
        [
          200,
          { "Content-Type" => "application/json" },
          latest_weather_hash.to_json
        ]
      end
    end

    before do
      stubbed_points_get
      stubbed_stations_get
      stubbed_latest_weather_get
    end

    it "returns a hash of weather data" do
      expect(subject).to eq(latest_weather_hash.deep_stringify_keys)
    end

    context "when a call to the NWS API fails" do
      let(:stubbed_points_get) do
        connection_stub.get("points/#{lat},#{long}") do
          [
            500,
            { "Content-Type" => "application/json" },
            "An unexpected error occurred."
          ]
        end
      end

      it "writes the error to logs" do
        expect(Rails.logger).to receive(:error).with(
          "Failed to fetch weather data at URL: #{described_class::NWS_API_BASE_URL}/points/#{lat},#{long}. " \
            "Status: 500"
        )

        begin
          subject
        rescue
        end
      end

      it "raises the error" do
        expect { subject }.to raise_error(WeatherSources::Errors::WeatherDataFetchError)
      end
    end
  end
end
