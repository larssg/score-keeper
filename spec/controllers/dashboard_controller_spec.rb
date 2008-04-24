require File.dirname(__FILE__) + '/../spec_helper'

describe DashboardController, 'logged in' do
  fixtures :users, :accounts
  
  before(:each) do
    @game = Factory.create_game
    controller.stub!(:current_game).and_return(@game)
    controller.stub!(:current_account).and_return(accounts(:champions))
    login_as :aaron
  end

  it "should show /index" do
    get :index
    response.should be_success
  end
end