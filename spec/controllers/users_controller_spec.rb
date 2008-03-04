require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  fixtures :users, :accounts
  
  before(:each) do
    controller.stub!(:current_account).and_return(accounts(:champions))
  end
  
  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire', :password_confirmation => 'quire',
      :name => 'Quire', :display_name => 'Mr. Quire' }.merge(options)
  end
end