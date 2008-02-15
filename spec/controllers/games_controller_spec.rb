require File.dirname(__FILE__) + '/../spec_helper'

describe GamesController, "logged in" do
  fixtures :users

  before(:each) do
    login_as :aaron
    @game = mock_model(Game)
    Game.stub!(:find_recent).and_return([@game])
  end
  
  it "should render" do
    get :index
    response.should be_success
  end
  
  it "should load games" do
    get :index
    assigns('games').first.should be_an_instance_of(Game)
  end
end

describe GamesController, 'not logged in' do
  it "should require login when trying to create a game" do
    post :create
    response.should be_redirect
    response.should redirect_to(login_url)
  end
end

describe GamesController, "creating a game (logged in)" do
  fixtures :users

  before(:each) do
    login_as :aaron
    @people = Factory.create_people(4)
    @params = 
      { :teams =>
        { 
          :score1 => 10,
          :user11 => @people[0].id,
          :user12 => @people[1].id,
          :score2 => 8,
          :user21 => @people[2].id,
          :user22 => @people[3].id
        }
      }
  end
  
  def do_post
    post :create, @params
  end
  
  it "should redirect to the dashboard" do
    do_post
    response.should be_redirect
    response.should redirect_to(dashboard_path)
  end
end