require File.dirname(__FILE__) + '/../spec_helper'

describe DashboardController do
  it "should show /index" do
    get :index
    response.should be_success
  end
end