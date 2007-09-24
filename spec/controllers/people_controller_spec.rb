require File.dirname(__FILE__) + '/../spec_helper'

describe PeopleController, 'not logged in' do
  before(:each) do
    @person = mock_model(Person, :first_name => 'John', :last_name => 'Doe')
    Person.stub!(:find).and_return([@person])
  end
  
  it "should show /index" do
    get :index
    response.should be_success
  end
  
  it "should require login when trying to edit a user" do
    get :edit, :id => @person.id
    response.should be_redirect
    response.should redirect_to(login_path)
  end
end