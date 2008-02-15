require File.dirname(__FILE__) + '/../spec_helper'

describe TeamsController, 'logged in' do
  fixtures :users

  before(:each) do
    login_as :aaron
  end

  it "should show /index" do
    get :index
    response.should be_success
  end
end