require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  before(:each) do
    @comment = Comment.new
  end
  
  it "should create a log entry" do
    match = Factory.create_match
    lambda do
      comment = Factory.create_comment(:match => match)
    end.should change(Log, :count).by(1)
  end
  
  it "should create a log entry linking to the game" do
    game = Factory.create_game
    match = Factory.create_match(:game => game)
    lambda do
      match = Factory.create_comment(:match => match)
    end.should change(Log, :count).by(1)
    
    log = Log.count(:conditions => { :game_id => game.id }).should == 2
  end
end
