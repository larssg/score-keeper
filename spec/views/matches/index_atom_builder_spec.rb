require File.dirname(__FILE__) + '/../../spec_helper'

describe "matches/index.atom.builder" do
  before(:each) do
    @account = Factory.create_account
    @game = Factory.create_game(:account => @account)
    @people = Factory.create_people(4, :account => @account)
    
    @matches = (0..4).collect { Factory.create_match(:account => @account, :game => @game, :people => @people) }
    assigns[:matches] = @matches
    assigns[:game] = @game
  end
  
  it "should render normal feed"
end