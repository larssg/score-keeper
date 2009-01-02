require File.dirname(__FILE__) + '/../spec_helper'

describe DashboardController, 'logged in' do
  fixtures :users, :accounts

  before(:each) do
    @game = Factory(:game)
    controller.stub!(:current_game).and_return(@game)
    controller.stub!(:current_account).and_return(@game.account)
    
    @user = Factory(:user, :account => @game.account)
    login_as @user
  end
  
  it "should show /index" do
    get :index
    response.should be_success
  end
end
