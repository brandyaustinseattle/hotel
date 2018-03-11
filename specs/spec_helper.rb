require 'simplecov'
SimpleCov.start

gem 'minitest', '>= 5.0.0'
require 'minitest/autorun'
require 'minitest/pride'

# Require_relative your lib files here!
require_relative '../lib/hotel_manager'
require_relative '../lib/reservation'
require_relative '../lib/room'
require_relative '../lib/block'
