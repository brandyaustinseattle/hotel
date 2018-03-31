require 'pry'

module Hotel
  class Block < Reservation

    attr_reader :discount, :group, :guest_list

    def initialize(input)
      super
      @discount = input[:discount]
      @group = input[:group]
      @guest_list = load_guest_list
    end

    def block?
      true
    end

    def range_match?(requested_start, requested_end)
      requested_start == @start_date && requested_end == @end_date
    end

    def find_total_cost
      super * @rooms.length * (1 - @discount)
    end

    def cost_per_guest
      self.find_total_cost / @rooms.length
    end

    def find_rooms_without_guest
      rooms_wo_guests = []

      @guest_list.keep_if {|room, guest|
      rooms_wo_guests << room if guest.nil?}

      return rooms_wo_guests
    end

    def assign_guest(room, name)
      raise StandardError("That room isn't part of #{@group}.") if !@rooms.include?(room)

      @guest_list[room] = name
    end

    private

    def load_guest_list
      guest_list = {}

      @rooms.each { |room| guest_list[room] = nil }

      return guest_list
    end

  end
end
