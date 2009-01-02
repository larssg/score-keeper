require File.dirname(__FILE__) + '/../spec_helper'

describe GamesController do
  fixtures :users, :accounts

  describe "with no games in the database" do
    before(:each) do
      @user = Factory(:user)
      controller.stub!(:current_game).and_return(nil)
      controller.stub!(:current_account).and_return(@user.account)
      login_as @user
    end

    it "should show #index" do
      get :index
      response.should be_success
    end
  end

  describe "with a game in the database" do
    before(:each) do
      @game = Factory(:game)
      @user = Factory(:user, :account => @game.account)
      controller.stub!(:current_game).and_return(@game)
      controller.stub!(:current_account).and_return(@game.account)
      login_as @user
    end
    
    # Delete this example and add some real ones
    it "should list the games" do
      get :index
      response.should be_success
      assigns[:games].should_not be_nil
      assigns[:games].size.should == 1
    end
  end
end
