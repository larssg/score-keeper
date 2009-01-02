#!/usr/bin/env ruby
#--
# Colour management with Ruby.
#
# Copyright 2005 Austin Ziegler
#   http://rubyforge.org/ruby-pdf/
#
#   Licensed under a MIT-style licence.
#
# $Id: test_css.rb,v 1.1 2005/08/08 02:44:17 austin Exp $
#++

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib") if __FILE__ == $0
require 'test/unit' unless defined? $ZENTEST and $ZENTEST
require 'color'
require 'color/css'

module TestColor
  class TestCSS < Test::Unit::TestCase
    def test_index
      assert_equal(Color::RGB::AliceBlue, Color::CSS[:aliceblue])
      assert_equal(Color::RGB::AliceBlue, Color::CSS["AliceBlue"])
      assert_equal(Color::RGB::AliceBlue, Color::CSS["aliceBlue"])
      assert_equal(Color::RGB::AliceBlue, Color::CSS["aliceblue"])
      assert_equal(Color::RGB::AliceBlue, Color::CSS[:AliceBlue])
    end
  end
end
