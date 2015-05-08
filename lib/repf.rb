require 'repf/solar'
require 'repf/wind'
require 'repf/generic_data'

class Array
  def even
    n = false
    self.select {|x| n = !n}
  end

  def odd
    n = true
    self.select {|x| n = !n}
  end

  def sum
    n = 0
    self.each {|x| n += x}
    n
  end

  def average
    self.sum / self.size
  end

end
