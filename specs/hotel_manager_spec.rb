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
    end
  end

  describe "create_block(requested_start:, requested_end:, group:, discount:, rooms_needed:) method" do

    it "adds a block to @all_reservations when one room" do
      @administrator.create_block( requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), group: "Sonics", discount: 0.10, rooms_needed: 1)

      @administrator.all_reservations.length.must_equal 1
      @administrator.all_reservations[0].block?.must_equal true
      @administrator.all_reservations[0].rooms.length.must_equal 1
    end

    it "adds a block to @all_reservations when some rooms" do
      @administrator.create_block( requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), group: "Sonics", discount: 0.10, rooms_needed: 3)

      @administrator.all_reservations.length.must_equal 1
      @administrator.all_reservations[0].block?.must_equal true
      @administrator.all_reservations[0].rooms.length.must_equal 3
    end

    it "raises an error if more than 5 rooms are needed" do
      proc{ @administrator.create_block( requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), group: "Sonics", discount: 0.10, rooms_needed: 8) }.must_raise StandardError
    end

    it "raises an error if there's not enough rooms due to prior reservations" do
      ten_day = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15),
      }

      lots_of_rooms = @administrator.all_rooms.take(18)
      lots_of_rooms.each {|room|
        ten_day[:room] = room
        Hotel::Reservation.new(ten_day)
      }

      proc{ @administrator.create_block( requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), group: "Sonics", discount: 0.10, rooms_needed: 5) }.must_raise StandardError
    end

  end

  describe "book_any_room(requested_start:, requested_end:, group:, guest:) method - general public" do
    it "raises error if requested_end is before requested_start" do
      proc{ @administrator.book_any_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,1)) }.must_raise StandardError
    end

    it "adds a reservation to @all_reservations" do
      @administrator.book_any_room(requested_start: Date.new(2018,3,1), requested_end: Date.new(2018,3,5))
      @administrator.all_reservations.length.must_equal 1
    end
  end

  describe "book_any_room(requested_start:, requested_end:, group:, guest:) method - block guest" do
    before do
      @administrator.create_block( requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), group: "Sonics", discount: 0.10, rooms_needed: 3)

      @administrator.book_any_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), group: "Sonics", guest: "Gary Payton")

      rooms = @administrator.all_rooms
      @room_one = rooms[0]
    end

    it "doesn't add a reservation to @all_reservations since block already created" do
      @administrator.all_reservations.length.must_equal 1
    end

    it "adds guest to the guest_list in block" do
      block = @administrator.all_reservations[0]
      block.guest_list[@room_one].must_equal "Gary Payton"
    end

    it "raises error if no rooms available" do
      2.times { @administrator.book_any_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), group: "Sonics", guest: "Shawn Kemp")}

      proc{ @administrator.book_any_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), group: "Sonics", guest: "Coach Malone") }.must_raise StandardError
    end
  end

  describe "book_specific_room(requested_start:, requested_end:, room_num:, group:, guest:) method - general public" do
    it "raises error if requested_end is before requested_start" do
      proc{ @administrator.book_specific_room(requested_start: Date.new(2018,3,15), requested_end: Date.new(2018,3,5), room_num: 1) }.must_raise StandardError
    end

    it "adds correct reservation to @all_reservations" do
      @administrator.book_specific_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), room_num: 1)
      @administrator.all_reservations.length.must_equal 1
      @administrator.all_reservations[0].start_date.must_equal Date.new(2018,3,5)
      @administrator.all_reservations[0].end_date.must_equal Date.new(2018,3,15)
    end

    it "returns an error if the room is not available for the given range" do
      room_8 = @administrator.all_rooms.find { |room| room.room_number == 8 }

      ten_day = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15),
        :rooms => room_8,
      }
      Hotel::Reservation.new(ten_day)

      proc{ @administrator.book_specific_room(requested_start: Date.new(2018,3,8), requested_end: Date.new(2018,3,5), room: 8) }.must_raise StandardError
    end
  end

  describe "book_specific_room(requested_start:, requested_end:, room_num:, group:, guest:) method - block guest" do
    before do
      @administrator.create_block( requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), group: "Sonics", discount: 0.10, rooms_needed: 3)

      @administrator.book_specific_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), room_num: 1, group: "Sonics", guest: "Gary Payton")

      rooms = @administrator.all_rooms
      @room_one = rooms[0]
    end

    it "doesn't add a reservation to @all_reservations since block already created" do
      @administrator.all_reservations.length.must_equal 1
    end

    it "adds guest to the guest_list in block" do
      block = @administrator.all_reservations[0]
      block.guest_list[@room_one].must_equal "Gary Payton"
    end

    it "raises error if room not available" do
      proc{ @administrator.book_specific_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), room_num: 1, group: "Sonics", guest: "Shawn Kemp")}.must_raise StandardError
    end
  end

  describe "find_reservations method" do
    it "returns one reservation when there's one on that date and one total" do
      @administrator.book_any_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15))
      applicable_reservations = @administrator.find_reservations(Date.new(2018,3,8))

      applicable_reservations.length.must_equal 1
      applicable_reservations[0].start_date.must_equal Date.new(2018,3,5)
      applicable_reservations[0].end_date.must_equal Date.new(2018,3,15)

    end

    it "returns one reservation when there's one on that date and many total" do
      @administrator.book_any_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15))
      @administrator.book_any_room(requested_start: Date.new(2018,3,2), requested_end: Date.new(2018,3,8))
      applicable_reservations = @administrator.find_reservations(Date.new(2018,3,3))

      applicable_reservations.length.must_equal 1
      applicable_reservations[0].start_date.must_equal Date.new(2018,3,2)
      applicable_reservations[0].end_date.must_equal Date.new(2018,3,8)
    end

    it "returns many reservations when there's many on that date" do
      @administrator.book_any_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15))
      @administrator.book_any_room(requested_start: Date.new(2018,3,2), requested_end: Date.new(2018,3,8))
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

  describe "find_rooms_general(date) method" do
    before do
      @ten_day = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15)
      }
    end

    it "returns all rooms when all available" do
      available_rooms = @administrator.find_rooms_general(Date.new(2018,3,1))

      available_rooms.length.must_equal 20
      available_rooms[0].must_be_kind_of Hotel::Room
      available_rooms[0].room_number.must_equal 1
    end

    it "returns many rooms when many rooms available" do
      @ten_day[:room] = 1
      reservation = Hotel::Reservation.new(@ten_day)
      this_room = @administrator.all_rooms.find {|room| room.room_number == 1}

      available_rooms = @administrator.find_rooms_general(Date.new(2018,3,10))

      available_rooms.length.must_equal 19
      available_rooms[0].must_be_kind_of Hotel::Room
      available_rooms[0].room_number.must_equal 2
    end

    it "returns one room when one room available" do
      (1..19).each {|num|
        @ten_day[:room] = num
        reservation = Hotel::Reservation.new(@ten_day)
        this_room = @administrator.all_rooms.find {|room| room.room_number == num}
      }

      available_rooms = @administrator.find_rooms_general(Date.new(2018,3,10))

      available_rooms.length.must_equal 1
      available_rooms[0].must_be_kind_of Hotel::Room
      available_rooms[0].room_number.must_equal 20
    end

    it "returns empty array when no rooms available" do
      (1..20).each {|num|
        @ten_day[:room] = num
        reservation = Hotel::Reservation.new(@ten_day)
        this_room = @administrator.all_rooms.find {|room| room.room_number == num}
      }

      available_rooms = @administrator.find_rooms_general(Date.new(2018,3,10))

      available_rooms.empty?.must_equal true
    end
  end

  describe "find_rooms_block(group) method" do
    before do
      @administrator.create_block( requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), group: "Sonics", discount: 0.10, rooms_needed: 3)

    end

    it "returns all rooms when all available" do
      block_rooms = @administrator.find_rooms_block("Sonics")
      block_rooms.length.must_equal 3
    end

    it "returns available rooms when only some are available" do
      @administrator.book_specific_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), room_num: 1, group: "Sonics", guest: "Gary Payton")

      block_rooms = @administrator.find_rooms_block("Sonics")
      block_rooms.length.must_equal 2
      block_rooms[0].room_number.must_equal 2
      block_rooms[1].room_number.must_equal 3
    end

    it "returns empty array when none are available" do
      (1..3).each {|num|
        @administrator.book_specific_room(requested_start: Date.new(2018,3,5), requested_end: Date.new(2018,3,15), room_num: num, group: "Sonics", guest: "Gary Payton")}

      block_rooms = @administrator.find_rooms_block("Sonics")
      block_rooms.empty?.must_equal true
    end
  end








  describe "available_date?(room, date, group) method - general public requesting with gen reservation in place" do
    before do
      @room = Hotel::Room.new(1)
      @av_date = Date.new(2018,2,5)

      @one_day = {
        :start_date => Date.new(2018,3,1),
        :end_date => Date.new(2018,3,2),
        :rooms => [@room]
      }
      @ten_day = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15),
        :rooms => [@room]
      }
    end

    it "returns true has if it has no reservations" do
      @administrator.available_date?(@room, @av_date, nil).must_equal true
    end

    it "returns true if room has one reservation, but still available" do
      Hotel::Reservation.new(@one_day)
      @administrator.available_date?(@room, @av_date, nil).must_equal true
    end

    it "returns true if room has multiple reservation, but still available" do
      Hotel::Reservation.new(@one_day)
      Hotel::Reservation.new(@ten_day)
      @administrator.available_date?(@room, @av_date, nil).must_equal true
    end

    it "returns false if room has one reservation and is unavailable" do
      Hotel::Reservation.new(@ten_day)
      sample_date = Date.new(2018,3,8)
      @administrator.available_date?(@room, sample_date, nil).must_equal false
    end

    it "returns false if room has multiple reservations and is unavailable" do
      Hotel::Reservation.new(@one_day)
      Hotel::Reservation.new(@ten_day)
      sample_date = Date.new(2018,3,8)
      @administrator.available_date?(@room, sample_date, nil).must_equal false
    end
  end

  describe "available_date?(date, group) method - general public requesting with block reservation in place" do
    before do
      @room = Hotel::Room.new(1)
      @extra_room = Hotel::Room.new(2)

      input = {
        :requested_start => Date.new(2018,3,5),
        :requested_end => Date.new(2018,3,15),
        :rooms_needed => 2,
        :discount => 0.10,
        :group => "Sonics"
      }
      @administrator.create_block(input)
      @block = @administrator.all_reservations[0]


      @av_date = Date.new(2018,2,5)
    end

    it "returns true if room has block, but still available" do
      @administrator.available_date?(@room, @av_date, nil).must_equal true
    end

    it "returns true if room has block that ends on request_date" do
      @administrator.available_date?(@room, Date.new(2018,3,15), nil).must_equal true
    end

    it "returns false if room has one block and not available" do
      @administrator.available_date?(@room, Date.new(2018,3,8), nil).must_equal false
    end
  end

  describe "available_date?(date, group) method - block guest requesting" do
    before do
      @room = Hotel::Room.new(1)
      @extra_room = Hotel::Room.new(2)

      input = {
        :requested_start => Date.new(2018,3,5),
        :requested_end => Date.new(2018,3,15),
        :rooms_needed => 2,
        :discount => 0.10,
        :group => "Sonics"
      }

      @administrator.create_block(input)
      @block = @administrator.all_reservations[0]
      # @block = Hotel::Block.new(input)

      @date = Date.new(2018,3,8)
    end

    it "returns true if room available in requested block" do
      @administrator.available_date?(@room, @date, "Sonics").must_equal true
    end

    it "returns false if room not available in requested block because guest has taken it already" do
      @block.assign_guest(@room, "Gary Payton")
      @administrator.available_date?(@room, @date, "Sonics").must_equal false
    end

    it "returns false if room not available in requested block because block doesn't exist for that group" do
      @administrator.available_date?(@room, @date, "Celtics").must_equal false
    end
  end

  describe "available_range?(start_date, end_date) method - general public requesting with gen reservation in place" do
    before do
      @room = Hotel::Room.new(1)

      ten_day = {
        :start_date => Date.new(2018,3,5),
        :end_date => Date.new(2018,3,15),
        :rooms => [@room]
      }

      Hotel::Reservation.new(ten_day)
    end

    it "raises error if start_date after end_date" do
      proc{ @administrator.available_range?(@room, Date.new(2018,3,2), Date.new(2018,3,1), nil).must_raise StandardError }
    end

    it "returns true if requested dates are before reservation dates" do
      start_date = Date.new(2018,2,5)
      end_date = Date.new(2018,2,8)
      @administrator.available_range?(@room, start_date, end_date, nil).must_equal true
    end

    it "returns true if requested dates are after reservation dates" do
      start_date = Date.new(2018,3,20)
      end_date = Date.new(2018,3,25)
      @administrator.available_range?(@room, start_date, end_date, nil).must_equal true
    end

    it "returns true if requested start_date matches reservation end_date" do
      start_date = Date.new(2018,3,15)
      end_date = Date.new(2018,3,20)
      @administrator.available_range?(@room, start_date, end_date, nil).must_equal true
    end

    it "returns false if requested dates and reservation dates have short overlap" do
      start_date = Date.new(2018,3,1)
      end_date = Date.new(2018,3,6)
      @administrator.available_range?(@room, start_date, end_date, nil).must_equal false
    end

    it "returns false if requested dates and reservation dates have long overlap" do
      start_date = Date.new(2018,3,1)
      end_date = Date.new(2018,3,13)
      @administrator.available_range?(@room, start_date, end_date, nil).must_equal false
    end
  end

  describe "available_range?(start_date, end_date) method - general public requesting with block reservation in place" do
    before do
      @room = Hotel::Room.new(1)
      @extra_room = Hotel::Room.new(2)

      input = {
        :requested_start => Date.new(2018,3,5),
        :requested_end => Date.new(2018,3,15),
        :rooms_needed => 2,
        :discount => 0.10,
        :group => "Sonics"
      }

      @administrator.create_block(input)
      @block = @administrator.all_reservations[0]
      # @block = Hotel::Block.new(input)
    end

    it "raises error if start_date after end_date" do
      proc{ @administrator.available_range?(@room, Date.new(2018,3,2), Date.new(2018,3,1), nil).must_raise StandardError }
    end

    it "returns true if requested dates are before reservation dates" do
      start_date = Date.new(2018,2,5)
      end_date = Date.new(2018,2,8)
      @administrator.available_range?(@room, start_date, end_date, nil).must_equal true
    end

    it "returns true if requested dates are after reservation dates" do
      start_date = Date.new(2018,3,20)
      end_date = Date.new(2018,3,25)
      @administrator.available_range?(@room, start_date, end_date, nil).must_equal true
    end

    it "returns true if requested start_date matches reservation end_date" do
      start_date = Date.new(2018,3,15)
      end_date = Date.new(2018,3,20)
      @administrator.available_range?(@room, start_date, end_date, nil).must_equal true
    end

    it "returns false if requested dates and reservation dates have short overlap" do
      start_date = Date.new(2018,3,1)
      end_date = Date.new(2018,3,6)
      @administrator.available_range?(@room, start_date, end_date, nil).must_equal false
    end

    it "returns false if requested dates and reservation dates have long overlap" do
      start_date = Date.new(2018,3,1)
      end_date = Date.new(2018,3,13)
      @administrator.available_range?(@room, start_date, end_date, nil).must_equal false
    end
  end

  describe "available_range?(requested_start, requested_end) method - block guest requesting" do
    before do
      @room = Hotel::Room.new(1)
      @extra_room = Hotel::Room.new(2)

      input = {
        :requested_start => Date.new(2018,3,5),
        :requested_end => Date.new(2018,3,15),
        :rooms_needed => 2,
        :discount => 0.10,
        :group => "Sonics"
      }

      @administrator.create_block(input)
      @block = @administrator.all_reservations[0]
      # @block = Hotel::Block.new(input)

      @requested_start = Date.new(2018,3,5)
      @requested_end = Date.new(2018,3,15)
    end

    it "returns true if room available in requested block" do
      @administrator.available_range?(@room, @requested_start, @requested_end, "Sonics").must_equal true
    end

    it "returns false if dates requested don't match block dates" do
      requested_end = Date.new(2018,3,10)
      @administrator.available_range?(@room, @requested_start, requested_end, "Sonics").must_equal false
    end

    it "returns false if room not available in requested block because guest has taken it already" do
      @block.assign_guest(@room, "Gary Payton")
      @administrator.available_range?(@room, @requested_start, @requested_end, "Sonics").must_equal false
    end

    it "returns false if room not available in requested block because block doesn't exist for that group" do
      @administrator.available_range?(@room, @requested_start, @requested_end, "Celtics").must_equal false
    end
  end


end
