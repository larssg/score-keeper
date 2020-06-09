# frozen_string_literal: true
module AuthenticatedTestHelper
  # Sets the current user in the session from the user fixtures.
  def login_as(user)
    if user.is_a? User
      @request.session[:user_id] = user.id
    else
      @request.session[:user_id] = user ? users(user).id : nil
    end
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'test') : nil
  end
end
