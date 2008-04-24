require File.dirname(__FILE__) + '/../spec_helper'

describe Match do
  before(:each) do
    @match = Match.new
  end
  
  it "should be created correctly by Factory" do
    lambda do
      @match = Factory.create_match
    end.should change(Match, :count).by(1)
    @match.should be_valid
  end
  
  it "should update rankings properly" do
    people = Factory.create_people(4)
    team_scores = [1, 0]
    game = Factory.create_game
    
    Factory.create_match(:people => people, :team_scores => team_scores, :game => game)
    
    [people[0], people[1]].each do |person|
      gp = person.game_participations.find_by_game_id(game.id)
      gp.ranking.should == 2020
      gp.matches_played.should == 1
    end
    
    [people[2], people[3]].each do |person|
      gp = person.game_participations.find_by_game_id(game.id)
      gp.ranking.should == 1980
      gp.matches_played.should == 1
    end
  end
  
  it "should update rankings properly when a game is deleted" do
    people = Factory.create_people(4)
    team_scores = [1, 0]
    game = Factory.create_game
    
    match = Factory.create_match(:people => people, :team_scores => team_scores, :game => game)
    
    match.destroy
    
    [people[0], people[1]].each do |person|
      gp = person.game_participations.find_by_game_id(game.id)
      gp.ranking.should == 2000
      gp.matches_played.should == 0
    end
    
    [people[2], people[3]].each do |person|
      gp = person.game_participations.find_by_game_id(game.id)
      gp.ranking.should == 2000
      gp.matches_played.should == 0
    end
  end
  
  it "should create a log entry" do
    lambda do
      match = Factory.create_match
    end.should change(Log, :count).by(1)
  end
  
  it "should create a log entry linking to the game" do
    game = Factory.create_game
    lambda do
      match = Factory.create_match(:game => game)
    end.should change(Log, :count).by(1)
    
    log = Log.find_by_game_id(game.id).should_not be_nil
  end
end