require File.dirname(__FILE__) + '/../spec_helper'

describe Match do
  before(:each) do
    @match = Match.new
  end
  
  it "should be created correctly by Factory" do
    lambda do
      @match = Factory(:match)
    end.should change(Match, :count).by(1)
    @match.should be_valid
  end
  
  it "should update rankings properly" do
    account = Factory(:account)
    score1 = 1
    team1 = (0..1).collect { Factory(:user, :account => account).id.to_s }
    score2 = 0
    team2 = (0..1).collect { Factory(:user, :account => account).id.to_s }
    game = Factory(:game, :account => account)
    
    Factory(:match, :score1 => score1, :team1 => team1, :score2 => score2, :team2 => team2, :game => game)
    
    team1.each do |user_id|
      user = User.find(user_id)
      gp = user.game_participations.find_by_game_id(game.id)
      gp.ranking.should == 2020
      gp.matches_played.should == 1
    end

    team2.each do |user_id|
      user = User.find(user_id)
      gp = user.game_participations.find_by_game_id(game.id)
      gp.ranking.should == 1980
      gp.matches_played.should == 1
    end
  end
  
  it "should update rankings properly when a game is deleted" do
    account = Factory(:account)
    score1 = 1
    team1 = (0..1).collect { Factory(:user, :account => account).id.to_s }
    score2 = 0
    team2 = (0..1).collect { Factory(:user, :account => account).id.to_s }
    game = Factory(:game, :account => account)
    
    match = Factory(:match, :score1 => score1, :team1 => team1, :score2 => score2, :team2 => team2, :game => game)
    
    match.destroy
    
    team1.each do |user_id|
      user = User.find(user_id)
      gp = user.game_participations.find_by_game_id(game.id)
      gp.ranking.should == 2000
      gp.matches_played.should == 0
    end

    team2.each do |user_id|
      user = User.find(user_id)
      gp = user.game_participations.find_by_game_id(game.id)
      gp.ranking.should == 2000
      gp.matches_played.should == 0
    end
  end
  
  it "should create a log entry" do
    lambda do
      match = Factory(:match)
    end.should change(Log, :count).by(1)
  end
  
  it "should create a log entry linking to the game" do
    game = Factory(:game)
    lambda do
      match = Factory(:match, :game => game)
    end.should change(Log, :count).by(1)
    
    log = Log.find_by_game_id(game.id).should_not be_nil
  end
end
