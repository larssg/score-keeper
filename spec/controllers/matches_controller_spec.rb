require File.dirname(__FILE__) + '/../spec_helper'

describe MatchesController do
  before(:each) do
    controller.stub!(:domain_required).and_return(true)
  end

  describe "logged in" do
    before(:each) do
      @game = Factory(:game)
      controller.stub!(:current_game).and_return(@game)
      controller.stub!(:current_account).and_return(@game.account)

      @user = Factory(:user, :account => @game.account)
      login_as @user

      @match = Factory(:match)
    end

    it "should render" do
      get :index
      response.should be_success
    end
  end

  describe 'not logged in' do
    it "should require login when trying to create a game" do
      post :create
      response.should be_redirect
      response.should redirect_to(login_url)
    end
  end

  describe "creating a match (logged in)" do
    before(:each) do
      @game = Factory(:game)
      controller.stub!(:current_game).and_return(@game)
      controller.stub!(:current_account).and_return(@game.account)

      @user = Factory(:user, :account => @game.account)
      login_as @user

      @team1 = (0..1).collect { Factory(:user, :account => @game.account).id.to_s }
      @team2 = (0..1).collect { Factory(:user, :account => @game.account).id.to_s }
    end

    def do_post(match = {})
      params = {
        :match => {
          :score1 => 10, :team1 => @team1,
          :score2 => 8, :team2 => @team2}.merge(match),
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

    describe "entering wrong data" do
      it "should not create a match" do
        lambda do
          do_post(:score1 => '')
        end.should_not change(Match, :count)
      end

      it "should redirect to the dashboard" do
        do_post(:score1 => '')
        response.should be_redirect
        response.should redirect_to(root_path)
      end

      it "should log an error" do
        do_post(:score1 => '')
        flash[:warning].should_not be_nil
        flash[:warning].should_not be_empty
      end
    end
  end

  describe "deleting a match" do
    fixtures :users, :accounts

    before(:each) do
      @game = Factory(:game)
      controller.stub!(:current_game).and_return(@game)
      controller.stub!(:current_account).and_return(@game.account)

      @user = Factory(:user, :account => @game.account)
      login_as @user
    end

    it "should work" do
      match = Factory(:match, :account => @game.account, :game => @game)
      lambda do
        delete :destroy, :id => match.id, :game_id => @game.id
      end.should change(Match, :count).by(-1)
    end

    it "should redirect to the match list" do
      match = Factory(:match, :account => @game.account, :game => @game)
      delete :destroy, :id => match.id, :game_id => @game.id
      response.should be_redirect
      response.should redirect_to(game_matches_path(@game))
      flash[:notice].should_not be_empty
    end

    it "should redirect to the match list when unsuccessful" do
      match = Factory(:match, :account => @game.account, :game => @game)
      match.destroy

      # now trying to delete a non-existing match
      delete :destroy, :id => match.id, :game_id => @game.id
      response.should be_redirect
      response.should redirect_to(game_matches_path(@game))
      flash[:warning].should_not be_empty
    end
  end
end

