require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
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
  
  it "should show /new" do
    get :new
    response.should be_success
  end
  
  describe "creating a user" do
    it "should add a user to the database" do
      lambda do
        create_user
      end.should change(User, :count).by(1)
    end

    it "should redirect to /index" do
      create_user
      response.should be_redirect
      response.should redirect_to(users_path)
    end
    
    describe "entering wrong data" do
      it "should add a user to the database" do
        lambda do
          create_user(:login => '')
        end.should_not change(User, :count)
      end
      
      it "should render the new form again" do
        create_user(:login => '')
        response.should be_success
        response.should render_template('users/new')
      end
    end
    
    describe "setting admin to true" do
      it "should work if the current user is an administrator" do
        current_user = mock_model(User, :time_zone => 'Copenhagen')
        current_user.should_receive(:is_admin?).and_return(true)
        controller.stub!(:current_user).and_return(current_user)
        
        create_user(:is_admin => true, :login => 'admin_user')
        User.find_by_login('admin_user').is_admin.should be_true
      end

      it "should not work if the current user is not an administrator" do
        current_user = mock_model(User, :time_zone => 'Copenhagen')
        current_user.should_receive(:is_admin?).and_return(false)
        controller.stub!(:current_user).and_return(current_user)

        create_user(:is_admin => true, :login => 'admin_user')
        User.find_by_login('admin_user').is_admin.should_not be_true
      end
    end
  end
  
  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire', :password_confirmation => 'quire',
      :name => 'Quire', :display_name => 'Mr. Quire' }.merge(options)
  end
end