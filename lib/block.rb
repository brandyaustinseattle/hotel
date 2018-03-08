require 'pry'

module Hotel
  class Block

    attr_reader :rooms_blocked, :discount_rate

    def initialize(input)
      @party = input[:party]
      @discount = input[:discount]
      @rooms_blocked = []
    end

  end
end
