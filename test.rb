require 'repf'
require 'repf/predictor/solar'

DATA_SIZE = 200
raw_data = []
DATA_SIZE.times do
  temp = ( 20 * (rand() * 3).to_i)
  raw_data << REPF::Solar.new( :capacity => 1000, :insolation => ( 700 + rand() * 600 ), :temperature => temp, :cloud_cover => ( rand() / 3 ) )
end

predictor = REPF::SolarPredictor.new(raw_data)
watts_err, avg_mse, r_squared = predictor.train

puts "\nPretraining prediction error: #{watts_err} watts (mse: #{avg_mse}%, r-squared: #{r_squared}\n"

watts_err, avg_mse, r_squared = predictor.validate
puts "\nAfter training prediction error: #{watts_err} watts (mse: #{avg_mse}%, r-squared: #{r_squared}\n"

puts "\nSamples of the difference between actual data and their predictions\n"

predictor.show_training
