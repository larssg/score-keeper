class UsersController < ApplicationController
  before_filter :login_required, :only => [ :index, :edit, :update ]
  before_filter :must_be_admin, :only => [ :index, :edit, :update ]
  
  def index
    @users = User.find(:all, :order => 'login')
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    @user.is_admin = params[:user][:is_admin]
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User changed.'[]
      redirect_to users_path
    else
      render :action => 'edit'
    end
  end

  # render new.rhtml
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.save!
    self.current_user = @user
    redirect_back_or_default('/')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  protected
  def must_be_admin
    return current_user.is_admin?
  end
end