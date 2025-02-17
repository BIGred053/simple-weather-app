class WeatherData
  def self.build(temp_unit = "F", latitude, longitude)
    {
      temperature: WeatherDataBuilders::TemperatureDataBuilder.build(temp_unit, latitude, longitude)
    }
  end
end
