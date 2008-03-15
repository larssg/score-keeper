require File.dirname(__FILE__) + '/../spec_helper'

describe Match, 'created by Factory' do
  before(:each) do
    @match = Match.new
  end

  it "should save successfully and be valid" do
    match = Factory.create_match
    match.should_not be_new_record
    match.should be_valid
  end
  
  it "should correctly determine the winner" do
    match = Factory.create_match
    match.winner.score.should == 10
  end
end

describe Match, "with people" do
  before(:each) do
    @people = Factory.create_people(4)
  end
  
  it "should update matches_won for users" do
    @people.each do |user|
      user.matches_won.should == 0
    end
    
    Factory.create_match(:people => @people, :team_scores => [10, 4])
    
    @people.each { |user| user.reload }
    @people[0].matches_won.should == 1
    @people[1].matches_won.should == 1
    @people[2].matches_won.should == 0
    @people[3].matches_won.should == 0
  end
  
  it "should update matches_won when destroyed" do
    match = Factory.create_match(:people => @people, :team_scores => [10, 4])
    match.destroy
    
    @people.each { |user| user.reload }
    @people.each do |user|
      user.matches_won.should == 0
    end
  end
  
  it "should update goals_for and goals_against for users" do
    @people.each do |user|
      user.goals_for.should == 0
      user.goals_against.should == 0
    end
    
    game = Factory.create_match(:people => @people, :team_scores => [10, 4])
    
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
    game = Factory.create_match(:people => @people, :team_scores => [10, 4])
    game.destroy
    
    @people.each do |user|
      user.goals_for.should == 0
      user.goals_against.should == 0
    end
  end
end