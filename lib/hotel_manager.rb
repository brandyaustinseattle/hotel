require 'pry'

module Hotel
  class Administrator

    attr_reader :all_rooms, :all_reservations, :all_blocks

    def initialize
      @all_rooms = load_rooms
      @all_reservations = []
      @all_blocks = []
    end

    def create_block(requested_start:, requested_end:, party:, discount:, rooms_needed:)

      rooms_available = @all_rooms.find_all {|room|
          room.available_range?(requested_start, requested_end)}

      if rooms_available.length < rooms_needed
        raiseStandardError("#{rooms_needed} rooms not available on those dates.")
      end

      rooms = rooms_available.take(rooms_needed)

      input = {
        :start_date => requested_start,
        :end_date => requested_end,
        :party => party,
        :discount => discount,
        :rooms => rooms
      }

      block = Hotel::Block.new(input)
      rooms.each {|room| room.add_block(block)}
      @all_blocks << block
    end

    def reserve_any_room(requested_start:, requested_end:)

      chosen_room = @all_rooms.find {|room|
        room.available_range?(requested_start, requested_end)}

      input = {
        :start_date => requested_start,
        :end_date => requested_end,
        :room => chosen_room,
      }

      reservation = Hotel::Reservation.new(input)
      chosen_room.add_reservation(reservation)
      @all_reservations << reservation
    end

    def reserve_specific_room(requested_start:, requested_end:, room_num:)

      requested_room = @all_rooms.find { |room| room.room_number == room_num }

      if requested_room.available_range?(requested_start, requested_end) == false
        raiseStandardError("Room #{room_num} is not available at that time.")
      end

      input = {
        :start_date => requested_start,
        :end_date => requested_end,
        :room => room_num,
      }

      reservation = Hotel::Reservation.new(input)
      requested_room.add_reservation(reservation)
      @all_reservations << reservation
    end

    def find_reservations(date)
      @all_reservations.find_all { |reservation|
      reservation.include_date?(date) }
    end

    # find available rooms not in block
    def find_rooms(date)
      @all_rooms.find_all { |room| room.available_date?(date) }
    end



    private

    def load_rooms
      rooms = []
      (1..20).each { |num| rooms << Room.new(num) }
      return rooms
    end

  end
end
