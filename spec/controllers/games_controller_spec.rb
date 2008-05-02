require File.dirname(__FILE__) + '/../spec_helper'

describe GamesController do
  fixtures :users, :accounts

  before(:each) do
    @game = Factory.create_game(:account => accounts(:champions))
    controller.stub!(:current_game).and_return(@game)
    controller.stub!(:current_account).and_return(accounts(:champions))
    login_as :aaron
  end

  #Delete this example and add some real ones
  it "should list the games" do
    get :index
    response.should be_success
    assigns[:games].should_not be_nil
    assigns[:games].size.should == 1
  end
end
