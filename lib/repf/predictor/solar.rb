require 'repf/predictor'

module REPF
  class SolarPredictor < Predictor

    attr_accessor :max_capacity, :max_insolation, :max_cloud_cover, :max_temperature

    def initialize(data_set = [])
      super

      self.max_capacity = determine_max_capacity
      self.max_insolation = determine_max_insolation
      self.max_cloud_cover = determine_max_cloud_cover
      self.max_temperature = determine_max_temperature
    end

    def determine_max_capacity
      max = 0
      @data_set.each do |data|
        max = data.capacity if data.capacity > max
      end
      max
    end

    def determine_max_insolation
      max = 0
      @data_set.each do |data|
        max = data.insolation if data.insolation > max
      end
      max
    end

    def determine_max_cloud_cover
      max = 0
      @data_set.each do |data|
        max = data.cloud_cover if data.cloud_cover > max
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

    def scale_input_and_output(data)
      input = [ scale( data.capacity, 0..max_capacity, 0..1 ),
                scale( data.insolation, 0..max_insolation, 0..1 ),
                scale( data.temperature, 0..max_temperature, 0..1 ),
                data.cloud_cover ]
      output = [ scale( data.instant_power, 0..max_watts, 0..1 ) ]
      [input, output]
    end

  end
end
