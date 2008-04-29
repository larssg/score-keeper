require File.expand_path(File.dirname(__FILE__) + '/../helper')

Story "signing up as a new user", %{
  As a new user
  I want to sign up
  So that I can register matches  
}, :type => RailsStory do
  
  Scenario "new user signs up" do
    Given "no users in the database" do
      Account.delete_all
      User.delete_all
    end
    When "I fill out the sign up form" do
      visits 'accounts/new'
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
end