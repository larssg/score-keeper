require File.dirname(__FILE__) + '/../spec_helper'

describe TeamsController, 'logged in' do
  before(:each) do
    @game = Factory(:game)
    controller.stub!(:current_game).and_return(@game)
    controller.stub!(:current_account).and_return(@game.account)
    controller.stub!(:domain_required).and_return(true)
    
    @user = Factory(:user, :account => @game.account)
    login_as @user
  end

  it "should show /index" do
    get :index
    response.should be_success
  end
end
