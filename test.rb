require 'repf.rb'
#require 'neural_net.rb'
require 'ruby-fann'

def scale(value, from_low, from_high, to_low, to_high)
  (value - from_low) * (to_high - to_low) / (from_high - from_low).to_f
end

def mse(actual, ideal)
  errors = actual.zip(ideal).map {|a, i| a - i }
  ( errors.inject(0) {|sum, err| sum += err**2} ) / errors.length.to_f
end

def run_test(neuralnet, inputs, expected_outputs)
  watts_err, errsum = 0, 0
  outputs = []

  inputs.each.with_index do |input, i|
    output = neuralnet.run input
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

def show_examples(neuralnet, x, y)
  puts "Actual\tPredict\tError (watts)"
  10.times do |i|
    output = neuralnet.run x[i]
    predicted = to_watts(output[0])
    actual = to_watts(y[i][0])
    puts "#{actual.round(1)}\t#{predicted.round(1)}\t#{(predicted - actual).abs.round(1)}"
  end
end

def to_watts(value)
  scale(value, 0, 1, 0, 1500)
end

raw_data = []
DATA_SIZE = 1000

DATA_SIZE.times do
  temp = ( 20 * (rand() * 3).to_i)
  raw_data << REPF::Solar.new( :capacity => 1000, :insolation => ( 700 + rand() * 600 ), :temperature => temp, :cloud_cover => ( rand() / 3 ).to_i )
end

input_stream = []
output_stream = []

raw_data.each do |d|
  inputs = [ scale( d.capacity, 0, 1500, 0, 1 ),
             scale( d.insolation, 0, 3000, 0, 1 ),
             scale( d.temperature, 0, 120, 0, 1 ),
             scale( d.cloud_cover, 0, 100, 0, 1 ) ]
  outputs = [ scale( d.instant_power, 0, 1500, 0, 1 ) ]
  input_stream << inputs
  output_stream << outputs
end

test_size = DATA_SIZE / 2
train_size = raw_data.length - test_size

#x_train = input_stream.slice(0, train_size)
x_train = input_stream.slice(0, raw_data.length)
#y_train = output_stream.slice(0, train_size)
y_train = output_stream.slice(0, raw_data.length)
x_test = input_stream.slice(train_size, test_size)
y_test = output_stream.slice(train_size, test_size)

#neuralnet = NeuralNet.new [4,4,1]
train = RubyFann::TrainData.new(:inputs => x_train, :desired_outputs => y_train)
neuralnet = RubyFann::Standard.new(:num_inputs => 4, :hidden_neurons => [4], :num_outputs => 1)

puts "Testing the untrained network..."
watts_err, avg_mse, r_squared = run_test(neuralnet, x_test, y_test)
puts "Average prediction error: #{watts_err.round(2)} watts (mse: #{(avg_mse * 100).round(2)}%, r-squared: #{r_squared.round(2)})"

puts "\nTraining the network...\n\n"
t1 = Time.now
#result = neuralnet.train(x_train, y_train, error_threshold: 0.0005,
#                                    max_iterations: 1000,
#                                    log_every: 50
#                                    )

neuralnet.train_on_data(train, 20000, 500, 0.00005)

# puts result
#puts "\nDone training the network: #{result[:iterations]} iterations, #{(result[:error] * 100).round(2)}% mse, #{(Time.now - t1).round(1)}s"

puts "\nTesting the trained network..."
watts_err, avg_mse, r_squared = run_test(neuralnet, x_test, y_test)
puts "Average prediction error: #{watts_err.round(2)} watts (mse: #{(avg_mse * 100).round(2)}%, r-squared: #{r_squared.round(2)})"

puts "\nTrained test examples (first 10):"
show_examples(neuralnet, x_test, y_test)
