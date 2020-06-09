class AccountsController < ApplicationController
  before_action :domain_required, :except => [ :new, :create ]
  before_action :login_required, :except => [ :new, :create ]
  before_action :must_be_admin, :except => [ :new, :create, :edit, :update ]
  before_action :must_be_account_admin, :only => [ :edit, :update ]

  def index
    order = %w(name created_at).include?(params[:order]) ? params[:order] : 'name'
    @accounts = Account.order(order)
  end

  def show
    @account = Account.find(params[:id])
    @account_users = @account.users.order('name').all
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

  def edit
    @account = current_account
  end

  def update
    if current_account.update_attributes(params[:account])
      flash[:notice] = 'Account saved.'
      redirect_to root_url
    else
      @account = current_account
      render :action => 'edit'
    end
  end

  protected
  def must_be_account_admin
    redirect_to root_url unless (current_user.account_id.to_s == params[:id] && current_user.is_account_admin?) || current_user.is_admin?
  end
end
