require File.dirname(__FILE__) + '/../spec_helper'

describe Team, 'having won a game' do
  before(:each) do
    @team = Team.new
  end

  it "should assign most points to player with lowest ranking" do
    amount = 30
    rankings = [1000, 2000]
    
    Team.split_award_points(amount, rankings).should == [20, 10]
  end
  
  it "should give rounding points to player with lowest ranking" do
    amount = 31
    rankings = [1000, 2000]
    
    Team.split_award_points(amount, rankings).should == [21, 10]
  end
end

describe Team, 'having lost a game' do
  before(:each) do
    @team = Team.new
  end

  it "should deduct most points from player with highest ranking" do
    amount = -30
    rankings = [1000, 2000]
    
    Team.split_award_points(amount, rankings).should == [-10, -20]
  end
  
  it "should deduct rounding points from player with highest ranking" do
    amount = -31
    rankings = [1000, 2000]
    
    Team.split_award_points(amount, rankings).should == [-10, -21]
  end
end

describe Team do
  before(:each) do
    @team = Team.new
  end
  
  it "should return 1 if it matches a filter with 1 person in it" do
    @team.team_ids = '1,2'
    @team.matches_filter('1').should be_true
    @team.matches_filter('2').should be_true
  end
  
  it "should return 0 if it does not match a filter with 1 person in it" do
    @team.team_ids = '1,2'
    @team.matches_filter('3').should be_false
  end
  
  it "should return 1 if it matches a filter with 2 people in it" do
    @team.team_ids = '1,2'
    @team.matches_filter('1,2').should be_true
  end
  
  it "should return 0 if it does not match a filter with 2 people in it" do
    @team.team_ids = '1,2'
    @team.matches_filter('2,3').should be_false
  end
end