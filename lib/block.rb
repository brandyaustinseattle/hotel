require 'pry'

module Hotel
  class Block < Reservation

    attr_reader :discount, :group, :guest

    def initialize(input)
      super
      @discount = input[:discount]
      @group = input[:group]
      @guest = nil
    end

    def block?
      true
    end

    def find_total_cost
      super * @rooms.length * (1 - @discount)
    end

    def cost_per_guest
      self.find_total_cost / @rooms.length
    end

    def assign_guest(name)
      @guest = name
    end

  end
end
