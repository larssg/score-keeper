require File.dirname(__FILE__) + '/../spec_helper'

describe PeopleController, 'not logged in' do
  before(:each) do
    @user = mock_model(User, :first_name => 'John', :last_name => 'Doe')
    User.stub!(:find).and_return([@user])
  end
  
  it "should show /index" do
    get :index
    response.should be_success
  end
  
  it "should require login when trying to edit a user" do
    get :edit, :id => @user.id
    response.should be_redirect
    response.should redirect_to(login_path)
  end
end