require File.dirname(__FILE__) + '/../spec_helper'

describe Team, 'having won a game' do
  before(:each) do
    @team = Team.new
  end

  it "should assign most points to the player with lowest ranking"
  
  it "should return 1 if it matches a filter with 1 person in it" do
    @team.team_ids = '1,2'
    @team.matches_filter('1').should == 1
    @team.matches_filter('2').should == 1
  end
  
  it "should return 0 if it does not match a filter with 1 person in it" do
    @team.team_ids = '1,2'
    @team.matches_filter('3').should == 0
  end
  
  it "should return 1 if it matches a filter with 2 people in it" do
    @team.team_ids = '1,2'
    @team.matches_filter('1,2').should == 1
  end
  
  it "should return 0 if it does not match a filter with 2 people in it" do
    @team.team_ids = '1,2'
    @team.matches_filter('2,3').should == 0
  end
end