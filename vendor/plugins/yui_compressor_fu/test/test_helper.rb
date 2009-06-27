require 'rubygems'
require 'action_view'
require 'test/unit'
require 'shoulda'
begin; require 'turn'; rescue LoadError; end
require File.join(File.dirname(__FILE__), '..', 'lib', 'yui_compressor_fu.rb')