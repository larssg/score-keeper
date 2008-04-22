require File.dirname(__FILE__) + '/../spec_helper'

describe Game do
  before(:each) do
    @game = Game.new(:name => 'Foosball')
  end

  it "should be valid" do
    @game.should be_valid
  end
end
