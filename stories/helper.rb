ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/rails/story_adapter'
require 'webrat'
require File.expand_path(File.dirname(__FILE__) + '/../spec/factory.rb')