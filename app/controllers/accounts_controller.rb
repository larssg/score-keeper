class AccountsController < ApplicationController
  session :off
  
  layout 'public'
  
  def new
    @account = Account.new
    @user = User.new
  end
  
  def create
    @account = Account.new(params[:account])
    @user = @account.users.build(params[:user])
    @user.is_account_admin = true
    
    if @account.save
      self.current_user = @user
      redirect_to account_url(@account.domain)
      flash[:notice] = "Thanks for signing up!"
    else
      flash[:notice] = 'An error occured - please try again.'
      render :action => 'new'
    end
  end
end