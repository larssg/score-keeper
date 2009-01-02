require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  it "should create a log entry" do
    match = Factory(:match)
    lambda do
      Factory(:comment, :match => match)
    end.should change(Log, :count).by(1)
  end
  
  it "should create a log entry linking to the game" do
    match = Factory(:match)
    lambda do
      Factory(:comment, :match => match)
    end.should change(Log, :count).by(1)
    
    log = Log.count(:conditions => { :game_id => match.game.id }).should == 2
  end
end
