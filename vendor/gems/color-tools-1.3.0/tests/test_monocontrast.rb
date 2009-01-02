#!/usr/bin/env ruby
#--
# Colour management with Ruby.
#
# Copyright 2005 Austin Ziegler
#   http://rubyforge.org/ruby-pdf/
#
#   Licensed under a MIT-style licence.
#
# $Id: test_monocontrast.rb,v 1.1 2005/08/08 02:44:17 austin Exp $
#++

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib") if __FILE__ == $0
require 'test/unit' unless defined? $ZENTEST and $ZENTEST
require 'color'
require 'color/palette/monocontrast'

module TestColor
  module TestPalette
    class TestMonoContrast < Test::Unit::TestCase
      include Color::Palette
      def setup
        @high = Color::RGB.from_html("#c9e3a6")
        @low  = Color::RGB.from_html("#746b8e")
        @mcp1 = MonoContrast.new(@high)
        @mcp2 = MonoContrast.new(@low)
      end

      def test_background
        assert_equal("#141711", @mcp1.background[-5].html)
        assert_equal("#32392a", @mcp1.background[-4].html)
        assert_equal("#657253", @mcp1.background[-3].html)
        assert_equal("#97aa7d", @mcp1.background[-2].html)
        assert_equal("#abc18d", @mcp1.background[-1].html)
        assert_equal("#c9e3a6", @mcp1.background[ 0].html)
        assert_equal("#d1e7b3", @mcp1.background[+1].html)
        assert_equal("#d7eabc", @mcp1.background[+2].html) # d7eabd
        assert_equal("#e4f1d3", @mcp1.background[+3].html) # e5f2d3
        assert_equal("#f2f8e9", @mcp1.background[+4].html) # f1f8e9
        assert_equal("#fafcf6", @mcp1.background[+5].html) # fafdf7

        assert_equal("#0c0b0e", @mcp2.background[-5].html)
        assert_equal("#1d1b24", @mcp2.background[-4].html)
        assert_equal("#3a3647", @mcp2.background[-3].html)
        assert_equal("#57506b", @mcp2.background[-2].html)
        assert_equal("#635b79", @mcp2.background[-1].html)
        assert_equal("#746b8e", @mcp2.background[ 0].html)
        assert_equal("#89819f", @mcp2.background[+1].html)
        assert_equal("#9790aa", @mcp2.background[+2].html) # 9790ab
        assert_equal("#bab5c7", @mcp2.background[+3].html) # bab6c7
        assert_equal("#dcdae3", @mcp2.background[+4].html)
        assert_equal("#f1f0f4", @mcp2.background[+5].html) # f2f1f4
      end

      def test_brightness_diff
        bd1 = @mcp1.brightness_diff(@high, @low)
        bd2 = @mcp1.brightness_diff(@low, @high)
        assert_in_delta(bd1, bd2, 1e-4)
      end

      def test_calculate_foreground
        assert_equal("#ffffff", @mcp1.calculate_foreground(@low, @high).html)
        assert_equal("#1d1b24", @mcp1.calculate_foreground(@high, @low).html)
      end

      def test_color_diff
        assert_in_delta(@mcp1.color_diff(@low, @high),
                        @mcp1.color_diff(@high, @low), 1e-4)
      end

      def test_foreground
        assert_equal("#c9e3a6", @mcp1.foreground[-5].html)
        assert_equal("#e4f1d3", @mcp1.foreground[-4].html) # e5f2d3
        assert_equal("#ffffff", @mcp1.foreground[-3].html)
        assert_equal("#000000", @mcp1.foreground[-2].html)
        assert_equal("#000000", @mcp1.foreground[-1].html)
        assert_equal("#000000", @mcp1.foreground[ 0].html)
        assert_equal("#000000", @mcp1.foreground[+1].html)
        assert_equal("#000000", @mcp1.foreground[+2].html)
        assert_equal("#32392a", @mcp1.foreground[+3].html)
        assert_equal("#32392a", @mcp1.foreground[+4].html)
        assert_equal("#32392a", @mcp1.foreground[+5].html)

        assert_equal("#bab5c7", @mcp2.foreground[-5].html) # bab6c7
        assert_equal("#dcdae3", @mcp2.foreground[-4].html)
        assert_equal("#ffffff", @mcp2.foreground[-3].html)
        assert_equal("#ffffff", @mcp2.foreground[-2].html)
        assert_equal("#ffffff", @mcp2.foreground[-1].html)
        assert_equal("#ffffff", @mcp2.foreground[ 0].html)
        assert_equal("#000000", @mcp2.foreground[+1].html)
        assert_equal("#000000", @mcp2.foreground[+2].html)
        assert_equal("#000000", @mcp2.foreground[+3].html)
        assert_equal("#1d1b24", @mcp2.foreground[+4].html)
        assert_equal("#3a3647", @mcp2.foreground[+5].html)
      end

      def test_minimum_brightness_diff
        assert_in_delta(MonoContrast::DEFAULT_MINIMUM_BRIGHTNESS_DIFF,
                        @mcp1.minimum_brightness_diff, 1e-4)
      end

      def test_minimum_brightness_diff_equals
        assert_in_delta(MonoContrast::DEFAULT_MINIMUM_BRIGHTNESS_DIFF,
                        @mcp1.minimum_brightness_diff, 1e-4)
        mcps = @mcp1.dup
        assert_nothing_raised { @mcp1.minimum_brightness_diff = 0.75 }
        assert_in_delta(0.75, @mcp1.minimum_brightness_diff, 1e-4)
        assert_not_equal(@mcp1.foreground[-5], mcps.foreground[-5])
        assert_nothing_raised { @mcp1.minimum_brightness_diff = 4.0 }
        assert_in_delta(1, @mcp1.minimum_brightness_diff, 1e-4)
        assert_nothing_raised { @mcp1.minimum_brightness_diff = -4.0 }
        assert_in_delta(0, @mcp1.minimum_brightness_diff, 1e-4)
        assert_nothing_raised { @mcp1.minimum_brightness_diff = nil }
        assert_in_delta(MonoContrast::DEFAULT_MINIMUM_BRIGHTNESS_DIFF,
                        @mcp1.minimum_brightness_diff, 1e-4)
      end

      def test_minimum_color_diff
        assert_in_delta(MonoContrast::DEFAULT_MINIMUM_COLOR_DIFF,
                        @mcp1.minimum_color_diff, 1e-4)
      end

      def test_minimum_color_diff_equals
        assert_in_delta(MonoContrast::DEFAULT_MINIMUM_COLOR_DIFF,
                        @mcp1.minimum_color_diff, 1e-4)
        mcps = @mcp1.dup
        assert_nothing_raised { @mcp1.minimum_color_diff = 0.75 }
        assert_in_delta(0.75, @mcp1.minimum_color_diff, 1e-4)
        assert_not_equal(@mcp1.foreground[-5], mcps.foreground[-5])
        assert_nothing_raised { @mcp1.minimum_color_diff = 4.0 }
        assert_in_delta(3, @mcp1.minimum_color_diff, 1e-4)
        assert_nothing_raised { @mcp1.minimum_color_diff = -4.0 }
        assert_in_delta(0, @mcp1.minimum_color_diff, 1e-4)
        assert_nothing_raised { @mcp1.minimum_color_diff = nil }
        assert_in_delta(MonoContrast::DEFAULT_MINIMUM_COLOR_DIFF,
                        @mcp1.minimum_color_diff, 1e-4)
      end

        # This is empty because the #regenerate method is automatically run
        # when changing the minimum_brightness_diff or minimum_color_diff.
      def test_regenerate
      end
    end
  end
end
