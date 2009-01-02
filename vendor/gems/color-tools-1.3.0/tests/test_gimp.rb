#!/usr/bin/env ruby
#--
# Colour management with Ruby.
#
# Copyright 2005 Austin Ziegler
#   http://rubyforge.org/ruby-pdf/
#
#   Licensed under a MIT-style licence.
#
# $Id: test_gimp.rb,v 1.1 2005/08/08 02:44:17 austin Exp $
#++

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib") if __FILE__ == $0
require 'test/unit' unless defined? $ZENTEST and $ZENTEST
require 'color'
require 'color/palette/gimp'

module TestColor
  module TestPalette
    class TestGimp < Test::Unit::TestCase
      def setup
        wsc = <<-EOS
GIMP Palette
Name: W3C Named Colors
Columns: 2
#
# ColorZilla W3C Named Colors
#
255 255 255 	White
255 255 0 	Yellow	
255 0 255 	Fuchsia
255 0 0		Red
192 192 192	Silver
128 128 128 	Gray
128 128 0	Olive	
128 0 128	Purple
128 0 0		Maroon
0 255 255	Aqua
0 255 0		Lime
0 128 128	Teal
0 128 0		Green
0 0 255		Blue
0 0 128		Navy
0 0 0 		Black 
        EOS
        @gimp = Color::Palette::Gimp.new(wsc)
      end

      def test_each
        assert_equal(16, @gimp.instance_variable_get(:@colors).size)
        @gimp.each { |el| assert_kind_of(Color::RGB, el) }
      end

      def test_each_name
        assert_equal(16, @gimp.instance_variable_get(:@names).size)
        
        @gimp.each_name { |color_name, color_set|
          assert_kind_of(Array, color_set)
          color_set.each { |el|
            assert_kind_of(Color::RGB, el)
          }
        }
      end

      def test_index
        assert_equal(Color::RGB::White, @gimp[0])
        assert_equal(Color::RGB::White, @gimp["White"][0])
      end

      def test_valid_eh
        assert(@gimp.valid?)
      end

      def test_name
        assert_equal("W3C Named Colors", @gimp.name)
      end
    end
  end
end
