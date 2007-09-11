require File.dirname(__FILE__) + '/../spec_helper'

describe Game do
  before(:each) do
    @game = Game.new
  end

  it "should be properly created by Factory" do
    game = Factory.create_game
    game.should_not be_new_record
    game.should be_valid
  end
end