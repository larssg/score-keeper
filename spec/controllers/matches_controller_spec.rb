require File.dirname(__FILE__) + '/../spec_helper'

describe MatchesController, "logged in" do
  fixtures :users, :accounts

  before(:each) do
    @game = Factory.create_game
    controller.stub!(:current_game).and_return(@game)
    controller.stub!(:current_account).and_return(accounts(:champions))
    login_as :aaron
    @match = mock_model(Match)
  end

  it "should render" do
    get :index
    response.should be_success
  end
end

describe MatchesController, 'not logged in' do
  it "should require login when trying to create a game" do
    post :create
    response.should be_redirect
    response.should redirect_to(login_url)
  end
end

describe MatchesController, "creating a match (logged in)" do
  fixtures :users, :accounts

  before(:each) do
    @game = Factory.create_game
    controller.stub!(:current_game).and_return(@game)
    controller.stub!(:current_account).and_return(accounts(:champions))
    login_as :aaron
    @people = Factory.create_people(4)
  end
  
  def do_post
    params = {
      :match => {
        :score1 => 10, :team1 => [@people[0].id, @people[1].id],
        :score2 => 8, :team2 => [@people[2].id, @people[3].id] },
      :game_id => @game.id }
    post :create, params
  end
  
  it "should redirect to the dashboard" do
    lambda do
      do_post
      response.should be_redirect
      response.should redirect_to(root_path)
    end
  end
  
  it "should create a match" do
    lambda do
      do_post
    end.should change(Match, :count).by(1)
  end
end

describe MatchesController, "deleting a match" do
  fixtures :users, :accounts

  before(:each) do
    @game = Factory.create_game
    controller.stub!(:current_game).and_return(@game)
    controller.stub!(:current_account).and_return(accounts(:champions))
    login_as :aaron
    @people = Factory.create_people(4)
  end
  
  it "should work" do
    match = Factory.create_match(:people => @people, :account => accounts(:champions), :game => @game)
    lambda do
      delete :destroy, :id => match.id, :game_id => @game.id
    end.should change(Match, :count).by(-1)
  end
  
  it "should redirect to the match list" do
    match = Factory.create_match(:people => @people, :account => accounts(:champions), :game => @game)
    delete :destroy, :id => match.id, :game_id => @game.id
    response.should be_redirect
    response.should redirect_to(game_matches_path(@game))
    flash[:notice].should_not be_empty
  end
  
  it "should redirect to the match list when unsuccessful" do
    match = Factory.create_match(:people => @people, :account => accounts(:champions), :game => @game)
    match.destroy
    
    # now trying to delete a non-existing match
    delete :destroy, :id => match.id, :game_id => @game.id
    response.should be_redirect
    response.should redirect_to(game_matches_path(@game))
    flash[:warning].should_not be_empty
  end
end