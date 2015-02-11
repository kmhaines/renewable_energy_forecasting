require 'ruby-fann'

module REPF

  class Predictor

    attr_accessor :max_watts, :neuralnet

    def initialize(data_set = [])
      @data_set = data_set

      self.max_watts = determine_max_watts
    end

    def determine_max_watts
      max = 0
      @data_set.each do |data|
        power = data.instant_power
        max = power if power > max
      end
      max
    end

    def scale(value, from_range, to_range)
      (value - from_range.begin) * (to_range.end - to_range.begin) / (from_range.end - from_range.begin).to_f
    end

    def mse(actual, ideal)
      errors = actual.zip(ideal).map {|a, i| a - i }
      ( errors.inject(0) {|sum, err| sum += err**2} ) / errors.length.to_f
    end

    def run_test(inputs, expected_outputs)
      watts_err, errsum = 0, 0
      outputs = []

      inputs.each.with_index do |input, i|
        output = @neuralnet.run input
        outputs << output
        watts_err += (to_watts(output[0]) - to_watts(expected_outputs[i][0])).abs
        errsum += mse(output, expected_outputs[i])
      end

      y_mean = expected_outputs.inject(0.0) { |sum, val| sum + val[0] } / expected_outputs.size
      y_sum_squares = expected_outputs.map{|val| (val[0] - y_mean)**2 }.reduce(:+)
      y_residual_sum_squares = outputs.zip(expected_outputs).map {|out, expected| (expected[0] - out[0])**2 }.reduce(:+)
      r_squared = 1.0 - (y_residual_sum_squares / y_sum_squares)

      [watts_err / inputs.length.to_f, errsum / inputs.length.to_f, r_squared]
    end

    def show_examples(x, y, count = 10)
      puts "Actual\tPredict\tError (watts)"
      count.times do |i|
        output = @neuralnet.run x[i]
        predicted = to_watts(output[0])
        actual = to_watts(y[i][0])
        puts "#{actual.round(1)}\t#{predicted.round(1)}\t#{(predicted - actual).abs.round(1)}"
      end
    end

    def to_watts(value)
      scale(value, 0..1, 0..max_watts)
    end

    def prepare
      @inputs, @desired_outputs = setup_training_data
    end

    def setup_training_data
      inputs = []
      desired_outputs = []

      @data_set.each do |d|
        input, output = scale_input_and_output(d)
        inputs << input
        desired_outputs << output
      end
      [inputs, desired_outputs]
    end

    def scale_input_and_output(data)
      [data.capacity,data.capacity]
    end

    def train
      prepare
      traindata = RubyFann::TrainData.new(:inputs => @inputs, :desired_outputs => @desired_outputs)
      @neuralnet = RubyFann::Standard.new(:num_inputs => input_neuron_count, :hidden_neurons => [hidden_neuron_count], :num_outputs => 1)

      data_length = @inputs.length
      testing_data_length = data_length / 2

      # Generate some statistics on the performance of the untrained network.
      watts_err, avg_mse, r_squared = run_test(@inputs[0..testing_data_length], @desired_outputs[0..testing_data_length])

      # puts "Average prediction error: #{watts_err.round(2)} watts (mse: #{(avg_mse * 100).round(2)}%, r-squared: #{r_squared.round(2)})"

      @neuralnet.train_on_data(traindata, 10000, 0, 0.00005)

      [watts_err.round(2), (avg_mse * 100).round(2), r_squared.round(2)]
    end

    def validate
      data_length = @inputs.length
      testing_data_length = data_length / 2
      watts_err, avg_mse, r_squared = run_test(@inputs[0..testing_data_length], @desired_outputs[0..testing_data_length])
      [watts_err.round(2), (avg_mse * 100).round(2), r_squared.round(2)]
    end

    def show_training(count = 10)
      data_length = @inputs.length
      testing_data_length = data_length / 2
      show_examples(@inputs[0..testing_data_length], @desired_outputs[0..testing_data_length],count)
    end

    def input_neuron_count
      4
    end

    def hidden_neuron_count
      4
    end

  end

end
