# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  layout 'login'
  before_filter :domain_required
  
  filter_parameter_logging :password

  # render new.rhtml
  def new
  end

  def create
    password_authentication(params[:login], params[:password])
  end
  
  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
  
  private
  def password_authentication(login, password)
    self.current_user = current_account.users.authenticate(login, password)
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { 
          :value => self.current_user.remember_token, :expires => self.current_user.remember_token_expires_at }
      end
      successful_login
    else
      failed_login('Invalid login or password')
    end
  end
  
  def successful_login
    redirect_to root_url
  end
  
  def failed_login(message)
    flash[:error] = message
    redirect_to login_url
  end
end