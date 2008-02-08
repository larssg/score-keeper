require File.dirname(__FILE__) + '/../spec_helper'

describe DashboardController, 'logged in' do
  fixtures :users

  it "should show /index" do
    login_as :aaron
    get :index
    response.should be_success
  end
end