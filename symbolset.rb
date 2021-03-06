#!/usr/bin/env ruby

# Class for a set of primitive symbols
# and their weights.
class SymbolSet
  def initialize
    @pairs = []
    @weight_accum = 0
  end

  # Add new symbol with its probability into the set
  def add_pair(symbol, weight)
    unless weight > 0 and weight < 100
      raise "Weight of symbol '#{symbol}' must be a value between 1 and 99."
    end

    # Insert new pair in the sorted array of pairs
    inserted = false
    @pairs.each_index do |index|
      if @pairs[index][1] > weight
        @pairs.insert(index, [symbol, weight])
        inserted = true
        break
      end
    end

    # Insert at the end, if requiered
    @pairs += [[symbol, weight]] unless inserted
    
    # Sum weights
    @weight_accum += weight
  end

  # Get a random symbol from the set
  def sample
    random = rand(@weight_accum)

    accum = 0
    @pairs.each_index do |index|
      accum += @pairs[index][1]
      return @pairs[index][0] if accum > random
    end
  end

  # Make Symbolset class appendable
  def +(other)
    load 'operators.rb'
    Append.new(self, other)
  end
end
