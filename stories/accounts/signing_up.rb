require File.expand_path(File.dirname(__FILE__) + '/../helper')

Story "Signing up as a new user", %{
  As a new user
  I want to sign up
  So that I can register matches  
}, :type => RailsStory do
  
  Scenario "New user signs up" do
    Given "no users in the database" do
      Account.delete_all
      User.delete_all
    end
    When "I go to the sign up form and fill it out" do
      visits "/p"
      clicks_link 'Sign up'
      fills_in 'Subdomain', 'test'
      fills_in 'Username', 'testuser'
      fills_in 'Email', 'testuser@test.example.com'
      fills_in 'Password', 'testpwd'
      fills_in 'Confirm Password', 'testpwd'
      clicks_button 'Sign up'
    end
    Then "I should have access to the system" do
      account = Account.find_by_domain('test')
      user = User.find_by_login('testuser')
      
      account.should_not be_nil
      user.should_not be_nil
      
      user.account.should == account
    end
  end
  
  Scenario "New user does not enter a subdomain" do
    Given "no users in the database"
    When "I fill out the sign up form with no subdomain" do
      visits 'accounts/new'
      fills_in 'Username', 'testuser'
      fills_in 'Email', 'testuser@test.example.com'
      fills_in 'Password', 'testpwd'
      fills_in 'Confirm Password', 'testpwd'
      clicks_button 'Sign up'
    end
    Then "I should not have access to the system" do
      account = Account.find_by_domain('test')
      user = User.find_by_login('testuser')
      
      account.should be_nil
      user.should be_nil
    end
  end
  
  Scenario "New user does not enter a username" do
    Given "no users in the database"
    When "I fill out the sign up form with no username" do
      visits 'accounts/new'
      fills_in 'Subdomain', 'test'
      fills_in 'Email', 'testuser@test.example.com'
      fills_in 'Password', 'testpwd'
      fills_in 'Confirm Password', 'testpwd'
      clicks_button 'Sign up'
    end
    Then "I should not have access to the system"  
  end

  Scenario "Test account already exists" do
    Given "a test account in the database" do
      Account.delete_all
      User.delete_all
      
      Account.create!(:domain => 'test')
    end
    When "I go to the sign up form and fill it out"
    Then "I should be told to use another account name" do
      response.should be_success
      response.should render_template('accounts/new')
      response.should have_text(/Domain has already been taken/)
    end
  end
end