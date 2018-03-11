require_relative 'spec_helper'
require 'pry'

describe "Block class" do
  before do
    administrator = Hotel::Administrator.new

    rooms = administrator.all_rooms.take(3)

    input = {
      :requested_start => Date.new(2018,3,5),
      :requested_end => Date.new(2018,3,15),
      :party => "Sonics",
      :discount => 0.10,
      :rooms => rooms
    }
    @block = Hotel::Block.new(input)
  end

  describe "initialize method" do
    it "creates an instance of block" do
      @block.must_be_kind_of Hotel::Block
    end

    it "is set up for specific attributes and data types" do
      @block.start_date.must_be_kind_of Date
      @block.end_date.must_be_kind_of Date

      @block.party.must_be_kind_of String
      @block.party.must_equal "Sonics"

      @block.discount.must_be_kind_of Float
      @block.discount.must_equal 0.10

      @block.rooms.must_be_kind_of Array
      @block.rooms[0].must_be_kind_of Hotel::Room
    end
  end

  describe "include_date?(date) method" do
    it "returns false if date not included in block" do
      date = Date.new(2018,2,1)
      @block.include_date?(date).must_equal false
    end

    it "returns true if date included in block" do
      date = Date.new(2018,3,8)
      @block.include_date?(date).must_equal true
    end

    it "returns false if date equals end date" do
      date = Date.new(2018,3,15)
      @block.include_date?(date).must_equal false
    end
  end

  describe "range_conflict?(requested_start, requested_end) method" do
    it "returns false if requested dates are before block dates" do
      requested_start = Date.new(2018,2,5)
      requested_end = Date.new(2018,2,8)
      @block.range_conflict?(requested_start, requested_end).must_equal false
    end

    it "returns false if requested dates are after block dates" do
      requested_start = Date.new(2018,3,20)
      requested_end = Date.new(2018,3,25)
      @block.range_conflict?(requested_start, requested_end).must_equal false
    end

    it "returns false if requested start_date matches block end_date" do
      requested_start = Date.new(2018,3,15)
      requested_end = Date.new(2018,3,20)
      @block.range_conflict?(requested_start, requested_end).must_equal false
    end

    it "returns true if requested dates and block dates have short overlap" do
      requested_start = Date.new(2018,3,1)
      requested_end = Date.new(2018,3,6)
      @block.range_conflict?(requested_start, requested_end).must_equal true
    end

    it "returns true if requested dates and block dates have long overlap" do
      requested_start = Date.new(2018,3,1)
      requested_end = Date.new(2018,3,13)
      @block.range_conflict?(requested_start, requested_end).must_equal true
    end
  end

end
