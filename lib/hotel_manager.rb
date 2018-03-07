require 'pry'

module Hotel
  class Administrator

    attr_reader :all_rooms, :all_reservations

    def initialize
      @all_rooms = load_rooms
      @all_reservations = []
    end

    def reserve_room(requested_start, requested_end)

      requested_start = Date.parse(requested_start)
      requested_end = Date.parse(requested_end)

      if requested_start > requested_end
        raiseStandardError("Start date is after end date.")
      end

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

    # X X X X X Need to finish testing
    def reserve_specfic_room(requested_start:, requested_end:, room:)
      room.available_range?(requested_start, requested_end)}
      room.add_reservation(reservation)
      @all_reservations << reservation
    end

    def find_reservations(date)
      # date = Date.new(date) if date.class != Date

      @all_reservations.find_all {|reservation|
      reservation.include_date?(date)}
    end

    def find_rooms(date)
      # date = Date.new(date) if date.class != Date
      @all_rooms.find_all {|room| room.available_date?(date)}
    end



    private

    def load_rooms
      rooms = []
      (1..20).each { |num| rooms << Room.new(num) }
      return rooms
    end

  end
end
