require 'repf'
require 'repf/predictor/wind'

DATA_SIZE = 200
raw_data = []
DATA_SIZE.times do
  temp = ( 20 * (rand() * 3).to_i)
  raw_data << REPF::Wind.new( :capacity => 1000, :wind => ( rand() * 15 ), :temperature => temp, :dew_point => (5 + ( ( rand() * 18 ).to_i ) ), :air_pressure => ( 98000 + ( ( rand() * 6000).to_i ) ) )
end

predictor = REPF::WindPredictor.new(raw_data)
watts_err, avg_mse, r_squared = predictor.train

puts "\nPretraining prediction error: #{watts_err} watts (mse: #{avg_mse}%, r-squared: #{r_squared})\n"

watts_err, avg_mse, r_squared = predictor.validate
puts "\nAfter training prediction error: #{watts_err} watts (mse: #{avg_mse}%, r-squared: #{r_squared})\n"

puts "\nSamples of the difference between actual data and their predictions\n"

predictor.show_training
