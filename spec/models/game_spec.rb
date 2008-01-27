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
  
  it "should properly find winner" do
    game = Factory.create_default_game
    game.winner.score.should == 10
  end
end

describe Game, "with people" do
  before(:each) do
    @people = Factory.create_people(4)
  end
  
  it "should update games_won for users" do
    @people.each do |user|
      user.games_won.should == 0
    end
    
    Factory.create_default_game(:people => @people, :team_scores => [10, 4])
    
    @people.each { |user| user.reload }
    @people[0].games_won.should == 1
    @people[1].games_won.should == 1
    @people[2].games_won.should == 0
    @people[3].games_won.should == 0
  end
  
  it "should update games_won when destroyed" do
    game = Factory.create_default_game(:people => @people, :team_scores => [10, 4])
    game.destroy
    
    @people.each { |user| user.reload }
    @people.each do |user|
      user.games_won.should == 0
    end
  end
  
  it "should update goals_for and goals_against for users" do
    @people.each do |user|
      user.goals_for.should == 0
      user.goals_against.should == 0
    end
    
    game = Factory.create_default_game(:people => @people, :team_scores => [10, 4])
    
    @people.each { |user| user.reload }
    @people[0].goals_for.should == 10
    @people[0].goals_against.should == 4
    @people[1].goals_for.should == 10
    @people[1].goals_against.should == 4
    @people[2].goals_for.should == 4
    @people[2].goals_against.should == 10
    @people[3].goals_for.should == 4
    @people[3].goals_against.should == 10
  end
  
  it "should update goals_for and goals_against when destroyed" do
    game = Factory.create_default_game(:people => @people, :team_scores => [10, 4])
    game.destroy
    
    @people.each do |user|
      user.goals_for.should == 0
      user.goals_against.should == 0
    end
  end
end