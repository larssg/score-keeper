require 'test_helper'

class FirstLoginTest < ActionController::IntegrationTest
  test "should be able to go to the dashboard on first login" do
    user = Factory(:user)
    login(user)
    
    get '/'
    assert_response :redirect
    assert_redirected_to '/games'

    get '/games'
    assert_response :success
  end

  test "should show /games/new" do
    user = Factory(:user)
    login(user)

    get '/games/new'
    assert_response :success
  end

  def login(user)
    post "http://#{user.account.domain}.example.com/sessions", :login => user.login, :password => user.password
    assert_response :redirect
    assert_redirected_to '/'
  end
end
