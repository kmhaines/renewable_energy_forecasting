require 'repf'
require 'repf/predictor/wind'

DATA_SIZE = 200
raw_data = []
DATA_SIZE.times do
  temp = ( 20 * (rand() * 3).to_i)
  raw_data << REPF::Wind.new( :capacity => 1000, :wind => ( rand() * 15 ), :temperature => temp, :dew_point => (5 + ( ( rand() * 18 ).to_i ) ), :air_pressure => ( 98000 + ( ( rand() * 6000).to_i ) ) )
end

puts "\nSample of the first 10 simulated measurements:\n"
puts "capacity\twind\ttemperature\t\tdew point\tair pressure\twatts\n"
raw_data[0..9].each do |wind|
  puts "#{wind.capacity}\t\t#{wind.wind.round(1)}\t\t#{wind.temperature}\t\t#{wind.dew_point.round(1)}\t\t#{wind.air_pressure.round(1)}\t\t#{wind.instant_power.round(1)}"
end

predictor = REPF::WindPredictor.new(raw_data)
watts_err, avg_mse, r_squared = predictor.train

puts "\nPretraining prediction error: #{watts_err} watts (mse: #{avg_mse}%, r-squared: #{r_squared})\n"

watts_err, avg_mse, r_squared = predictor.validate
puts "\nAfter training prediction error: #{watts_err} watts (mse: #{avg_mse}%, r-squared: #{r_squared})\n"

puts "\nSamples of the difference between actual data and their predictions\n"

predictor.show_training
