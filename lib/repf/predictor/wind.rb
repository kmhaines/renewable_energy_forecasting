require 'repf/predictor'

module REPF
  class WindPredictor < Predictor

    attr_accessor :max_wind, :max_cutin, :max_rated_peak_wind, :max_temperature, :max_dew_point, :max_air_pressure

    def initialize(data_set = [])
      puts "initialize"
      super

      self.max_wind = determine_max_wind
      self.max_cutin = determine_max_cutin
      self.max_rated_peak_wind = determine_max_rated_peak_wind
      self.max_temperature = determine_max_temperature
      self.max_dew_point = determine_max_dew_point
      self.max_air_pressure = determine_max_air_pressure
    end

    def determine_max_wind
      max = 0
      @data_set.each do |data|
        max = data.wind if data.wind > max
      end
      max
    end

    def determine_max_cutin
      max = 0
      @data_set.each do |data|
        max = data.cutin if data.cutin > max
      end
      max
    end

    def determine_max_rated_peak_wind
      max = 0
      @data_set.each do |data|
        max = data.rated_peak_wind if data.rated_peak_wind > max
      end
      max
    end

    def determine_max_temperature
      max = 0
      @data_set.each do |data|
        max = data.temperature if data.temperature > max
      end
      max
    end

    def determine_max_dew_point
      max = 0
      @data_set.each do |data|
        max = data.dew_point if data.dew_point > max
      end
      max
    end

    def determine_max_air_pressure
      max = 0
      @data_set.each do |data|
        max = data.air_pressure if data.air_pressure > max
      end
      max
    end

    def scale_input_and_output(data)
      input = [ scale( data.wind, 0..max_wind, 0..1 ),
                scale( data.cutin, 0..max_cutin, 0..1 ),
                scale( data.rated_peak_wind, 0..max_rated_peak_wind, 0..1 ),
                scale( data.temperature, 0..max_temperature, 0..1 ),
                scale( data.dew_point, 0..max_dew_point, 0..1 ),
                scale( data.air_pressure, 0..max_air_pressure, 0..1 ), ]
      output = [ scale( data.instant_power, 0..max_watts, 0..1 ) ]
      [input, output]
    end

    def input_neuron_count
      6
    end

    def hidden_neuron_count
      6
    end

  end
end
