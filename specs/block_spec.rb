require_relative 'spec_helper'
require 'pry'

describe "Block class" do
  before do
    administrator = Hotel::Administrator.new
    @rooms = administrator.all_rooms.take(3)

    @one_day = {
      :start_date => Date.new(2018,3,1),
      :end_date => Date.new(2018,3,2),
      :rooms => @rooms,
      :discount => 0.10,
      :group => "Spurs",
    }

    @ten_day = {
      :start_date => Date.new(2018,3,5),
      :end_date => Date.new(2018,3,15),
      :rooms => @rooms,
      :discount => 0.10,
      :group => "Sonics",
    }

    @block = Hotel::Block.new(@ten_day)
  end

  describe "initialize method" do
    it "creates an instance of block" do
      @block.must_be_kind_of Hotel::Block
    end

    it "is set up for specific attributes and data types" do
      @block.start_date.must_be_kind_of Date
      @block.end_date.must_be_kind_of Date

      @block.rooms.must_be_kind_of Array
      @block.rooms[0].must_be_kind_of Hotel::Room

      @block.discount.must_be_kind_of Float
      @block.discount.must_equal 0.10

      @block.group.must_be_kind_of String
      @block.group.must_equal "Sonics"

      @block.guest.nil?.must_equal true
    end
  end

  describe "find_total_cost method" do
    it "returns correct amount when stay is one night long" do
      block = Hotel::Block.new(@one_day)
      block.find_total_cost.must_equal 540.0
    end

    it "returns correct amount when stay is many nights long" do
      block = Hotel::Block.new(@ten_day)
      block.find_total_cost.must_equal 5400.0
    end
  end

  describe "cost_per_guest method" do
    it "returns correct amount when stay is one night long" do
      block = Hotel::Block.new (@one_day)
      block.cost_per_guest.must_equal 180.0
    end

    it "returns correct amount when stay is many nights long" do
      block = Hotel::Block.new (@ten_day)
      block.cost_per_guest.must_equal 1800.0
    end
  end

  describe "assign_guest method" do
    it "assigns guest to instance of block" do
      block = Hotel::Block.new (@ten_day)
      block.guest.nil?.must_equal true
      block.assign_guest("Gary Payton")
      block.guest.must_equal "Gary Payton"
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

  describe "range_conflict?(start_date, end_date) method" do
    it "returns false if requested dates are before block dates" do
      start_date = Date.new(2018,2,5)
      end_date = Date.new(2018,2,8)
      @block.range_conflict?(start_date, end_date).must_equal false
    end

    it "returns false if requested dates are after block dates" do
      start_date = Date.new(2018,3,20)
      end_date = Date.new(2018,3,25)
      @block.range_conflict?(start_date, end_date).must_equal false
    end

    it "returns false if requested start_date matches block end_date" do
      start_date = Date.new(2018,3,15)
      end_date = Date.new(2018,3,20)
      @block.range_conflict?(start_date, end_date).must_equal false
    end

    it "returns true if requested dates and block dates have short overlap" do
      start_date = Date.new(2018,3,1)
      end_date = Date.new(2018,3,6)
      @block.range_conflict?(start_date, end_date).must_equal true
    end

    it "returns true if requested dates and block dates have long overlap" do
      start_date = Date.new(2018,3,1)
      end_date = Date.new(2018,3,13)
      @block.range_conflict?(start_date, end_date).must_equal true
    end
  end

end
