require 'pry'

module Hotel
  class Administrator

    attr_reader :all_rooms, :all_reservations

    def initialize
      @all_rooms = load_rooms
      @all_reservations = []
    end

    def create_block(requested_start:, requested_end:, group:, discount:, rooms_needed:)

      if rooms_needed > 5
        raiseStandardError("Blocks can't contain more than 5 rooms.")
      end

      rooms_available = @all_rooms.find_all {|room|
          room.available_range?(requested_start, requested_end, nil)}

      if rooms_available.length < rooms_needed
        raiseStandardError("#{rooms_needed} rooms not available on those dates.")
      end

      rooms = rooms_available.take(rooms_needed)

      input = {
        :start_date => requested_start,
        :end_date => requested_end,
        :rooms => rooms,
        :discount => discount,
        :group => group
      }

      block = Hotel::Block.new(input)
      rooms.each {|room| room.add_reservation(block)}
      @all_reservations << block
    end

    def book_any_room(requested_start:, requested_end:, group: nil, guest: nil)

      date_check(requested_start, requested_end)

      chosen_room = @all_rooms.find {|room|
        room.available_range?(requested_start, requested_end, group)}

      raise StandardError("No rooms available. Check start and end dates if reserving a block room.") if chosen_room.nil?

      process_booking(requested_start, requested_end, chosen_room, group, guest)
    end

    def book_specific_room(requested_start:, requested_end:, room_num:, group: nil, guest:nil)

      date_check(requested_start, requested_end)

      requested_room = @all_rooms.find { |room| room.room_number == room_num }

      if requested_room.available_range?(requested_start, requested_end, group) == false
        raise StandardError("Room #{room_num} is not available at that time.")
      end

      process_booking(requested_start, requested_end, requested_room, group, guest)
    end

    def process_booking(requested_start, requested_end, room, group, guest)
      if group.nil?
        input = {
          :start_date => requested_start,
          :end_date => requested_end,
          :rooms => [room],
        }

        new_reservation = Hotel::Reservation.new(input)
        room.add_reservation(new_reservation)
        @all_reservations << new_reservation
      else
        related_reservation = @all_reservations.find {|reservation|
          reservation.start_date == requested_start &&
          reservation.end_date == requested_end &&
          reservation.rooms.include?(room)}

        related_reservation.assign_guest(room, guest)
      end
    end
    
    
    # WITH ADDT TIME FOR REFACTORING, I WOULD REDO MY BOOKING METHODS SO THAT THEY LEVERAGED THE 
    # FIND_RESERVATIONS, FIND_ROOMS_GENERAL, AND FIND_ROOMS_BLOCK FUNCTIONS BELOW
    # THIS WAS LESS FEASIBLE WITH MY CURRENT SET UP BECAUSE I TREATED BOOKING THE SAME REGARDLESS OF WHETHER BLOCKS WERE INVOLVED

    # find all reservations, general reservations and block reservations
    # block reservations may or may not be available to book
    def find_reservations(date)
      @all_reservations.find_all { |reservation|
      reservation.include_date?(date) }
    end

    # find rooms available to book for the general public
    def find_rooms_general(date)
      @all_rooms.find_all { |room| room.available_date?(date, nil) }
    end

    # find rooms available for the block guest
    # assumes no two blocks have the same name
    def find_rooms_block(group)
      block = @all_reservations.find { |reservation|
      reservation.group == group}

      block.find_rooms_without_guest
    end

    private

    def load_rooms
      rooms = []
      (1..20).each { |num| rooms << Room.new(num) }
      return rooms
    end

    def date_check(requested_start, requested_end)
      raise StandardError("End date is before start date.") if requested_start > requested_end

    end

  end
end
