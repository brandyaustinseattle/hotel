require_relative 'spec_helper'
require 'pry'

describe "Administrator class" do
  before do
    @administrator = Hotel::Administrator.new
  end

  describe "initialize method" do
    it "creates an instance of administrator" do
      @administrator.must_be_kind_of Hotel::Administrator
    end

    it "is set up for specific attributes and data types" do
      @administrator.all_rooms.must_be_kind_of Array
      @administrator.all_rooms.length.must_equal 20
      @administrator.all_reservations.must_be_kind_of Array
      @administrator.all_reservations.empty?.must_equal true
      @administrator.all_blocks.must_be_kind_of Array
      @administrator.all_blocks.empty?.must_equal true
    end
  end

  describe "create_block(requested_start:, requested_end:, party:, discount:, rooms_needed:) method" do

    it "adds a block to @all_blocks when one room" do
      @administrator.create_block( requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), party: "Sonics", discount: 0.10, rooms_needed: 1)

      @administrator.all_blocks.length.must_equal 1
      @administrator.all_blocks[0].rooms.length.must_equal 1
    end

    it "adds a block to @all_blocks when some rooms" do
      @administrator.create_block( requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), party: "Sonics", discount: 0.10, rooms_needed: 3)

      @administrator.all_blocks.length.must_equal 1
      @administrator.all_blocks[0].rooms.length.must_equal 3
    end

    it "adds a block to @all_blocks when many room" do
      @administrator.create_block( requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), party: "Sonics", discount: 0.10, rooms_needed: 18)

      @administrator.all_blocks.length.must_equal 1
      @administrator.all_blocks[0].rooms.length.must_equal 18
    end

    it "raises an error if there's not enough rooms due to number requested" do
      proc{ @administrator.create_block( requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), party: "Sonics", discount: 0.10, rooms_needed: 25) }.must_raise StandardError
    end

    it "raises an error if there's not enough rooms due to prior reservations" do
      8.times {@administrator.reserve_any_room(requested_start: Date.new(2018,3,1), requested_end: Date.new(2018,3,8))}

      proc{ @administrator.create_block( requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), party: "Sonics", discount: 0.10, rooms_needed: 15) }.must_raise StandardError
    end

    it "adds a block to all impacted room instances" do
      @administrator.create_block( requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), party: "Sonics", discount: 0.10, rooms_needed: 3)

      @administrator.all_rooms[0].blocks.length.must_equal 1
      @administrator.all_rooms[1].blocks.length.must_equal 1
      @administrator.all_rooms[2].blocks.length.must_equal 1
    end
  end

  describe "reserve_any_room(requested_start:, requested_end:) method" do
    it "raises error if requested_end is before requested_start" do
      proc{ @administrator.reserve_any_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,1)) }.must_raise StandardError
    end

    it "adds a reservation to @all_reservations" do
      @administrator.reserve_any_room(requested_start: Date.new(2018,3,1), requested_end: Date.new(2018,3,5))
      @administrator.all_reservations.length.must_equal 1
    end

    it "adds a reservation to the room instance when room 1" do
      @administrator.reserve_any_room(requested_start: Date.new(2018,3,1), requested_end: Date.new(2018,3,5))
      rooms = @administrator.all_rooms
      rooms[0].reservations.length.must_equal 1
      rooms[0].room_number.must_equal 1
    end

    it "adds a reservation to the room instance when not room 1" do
      @administrator.reserve_any_room(requested_start: Date.new(2018,3,1), requested_end: Date.new(2018,3,5))
      @administrator.reserve_any_room(requested_start: Date.new(2018,3,1), requested_end: Date.new(2018,3,8))
      rooms = @administrator.all_rooms
      rooms[1].reservations.length.must_equal 1
      rooms[1].room_number.must_equal 2
    end
  end

  describe "reserve_specific_room(requested_start:, requested_end:, room_num:) method" do
    it "raises error if requested_end is before requested_start" do
      proc{ @administrator.reserve_specific_room(requested_start: Date.new(2018,3,15), requested_end: Date.new(2018,3,5), room_num: 1) }.must_raise StandardError
    end

    it "adds correct reservation to @all_reservations when room available" do
      @administrator.reserve_specific_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), room_num: 1)
      @administrator.all_reservations.length.must_equal 1
      @administrator.all_reservations[0].start_date.must_equal Date.new(2018,3,5)
      @administrator.all_reservations[0].end_date.must_equal Date.new(2018,3,15)
    end

    it "adds correct reservation to the room instance when room 1" do
      @administrator.reserve_specific_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), room_num: 1)
      rooms = @administrator.all_rooms
      rooms[0].reservations.length.must_equal 1
      rooms[0].room_number.must_equal 1
    end

    it "adds correct reservation to the room instance when not room 1" do
      @administrator.reserve_specific_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), room_num: 8)
      rooms = @administrator.all_rooms
      rooms[7].reservations.length.must_equal 1
      rooms[7].room_number.must_equal 8
    end

    it "reserves the room requested for the given date range" do
      @administrator.reserve_specific_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), room_num: 8)
      rooms = @administrator.all_rooms
      room_8 = rooms.find { |room| room.room_number == 8 }
      room_8.reservations.length.must_equal 1
      room_8.reservations[0].start_date.must_equal Date.new(2018,3,5)
      room_8.reservations[0].end_date.must_equal Date.new(2018,3,15)
    end

    it "returns an error if the room is not available for the given range" do
      room_8 = @administrator.all_rooms.find { |room| room.room_number == 8 }

      ten_day = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15),
        :room => 1,
      }
      room_8.add_reservation(ten_day)

      proc{ @administrator.reserve_specific_room(requested_start: Date.new(2018,3,8), requested_end: Date.new(2018,3,5), room: 8) }.must_raise StandardError
    end
  end

  describe "find_reservations method" do
    it "returns one reservation when there's one on that date and one total" do
      @administrator.reserve_any_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15))
      applicable_reservations = @administrator.find_reservations(Date.new(2018,3,8))

      applicable_reservations.length.must_equal 1
      applicable_reservations[0].start_date.must_equal Date.new(2018,3,5)
      applicable_reservations[0].end_date.must_equal Date.new(2018,3,15)

    end

    it "returns one reservation when there's one on that date and many total" do
      @administrator.reserve_any_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15))
      @administrator.reserve_any_room(requested_start: Date.new(2018,3,2), requested_end: Date.new(2018,3,8))
      applicable_reservations = @administrator.find_reservations(Date.new(2018,3,3))

      applicable_reservations.length.must_equal 1
      applicable_reservations[0].start_date.must_equal Date.new(2018,3,2)
      applicable_reservations[0].end_date.must_equal Date.new(2018,3,8)
    end

    it "returns many reservations when there's many on that date" do
      @administrator.reserve_any_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15))
      @administrator.reserve_any_room(requested_start: Date.new(2018,3,2), requested_end: Date.new(2018,3,8))
      applicable_reservations = @administrator.find_reservations(Date.new(2018,3,6))

      applicable_reservations.length.must_equal 2
      applicable_reservations[0].start_date.must_equal Date.new(2018,3,5)
      applicable_reservations[0].end_date.must_equal Date.new(2018,3,15)
      applicable_reservations[1].start_date.must_equal Date.new(2018,3,2)
      applicable_reservations[1].end_date.must_equal Date.new(2018,3,8)
    end

    it "returns empty_array when there's no reservations on that date" do
      @administrator.find_reservations(Date.new(2018,5,1)).empty?.must_equal true
    end
  end

  describe "find_rooms(date) method" do
    before do
      @ten_day = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15)
      }
    end

    it "returns all rooms when all available" do
      available_rooms = @administrator.find_rooms(Date.new(2018,3,1))

      available_rooms.length.must_equal 20
      available_rooms[0].must_be_kind_of Hotel::Room
      available_rooms[0].room_number.must_equal 1
    end

    it "returns many rooms when many rooms available" do
      @ten_day[:room] = 1
      reservation = Hotel::Reservation.new(@ten_day)
      this_room = @administrator.all_rooms.find {|room| room.room_number == 1}
      this_room.add_reservation(reservation)

      available_rooms = @administrator.find_rooms(Date.new(2018,3,10))

      available_rooms.length.must_equal 19
      available_rooms[0].must_be_kind_of Hotel::Room
      available_rooms[0].room_number.must_equal 2
    end

    it "returns one room when one room available" do
      (1..19).each {|num|
        @ten_day[:room] = num
        reservation = Hotel::Reservation.new(@ten_day)
        this_room = @administrator.all_rooms.find {|room| room.room_number == num}
        this_room.add_reservation(reservation)
      }

      available_rooms = @administrator.find_rooms(Date.new(2018,3,10))

      available_rooms.length.must_equal 1
      available_rooms[0].must_be_kind_of Hotel::Room
      available_rooms[0].room_number.must_equal 20
    end

    it "returns empty array when no rooms available" do
      (1..20).each {|num|
        @ten_day[:room] = num
        reservation = Hotel::Reservation.new(@ten_day)
        this_room = @administrator.all_rooms.find {|room| room.room_number == num}
        this_room.add_reservation(reservation)
      }

      available_rooms = @administrator.find_rooms(Date.new(2018,3,10))

      available_rooms.empty?.must_equal true
    end
  end

end
