require File.dirname(__FILE__) + '/../spec_helper'

describe GamesController, "index page" do
  before(:each) do
    login_as Factory.create_user
    @game = mock_model(Game)
    Game.stub!(:find_recent).and_return([@game])
  end
  
  it "should render" do
    get :index
    response.should be_success
  end
  
  it "should load games" do
    get :index
    assigns('games').first.should an_instance_of(Game)
  end
end