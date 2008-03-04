class AccountsController < ApplicationController
  session :off, :only => [ :new, :create ]
  before_filter :must_be_admin, :except => [ :new, :create ]
  
  def index
    @accounts = Account.find(:all, :order => 'name')
  end
  
  def show
    @account = Account.find(params[:id])
  end
  
  def new
    @account = Account.new
    @user = User.new
    render :layout => 'public'
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
      render :action => 'new', :layout => 'public'
    end
  end
end