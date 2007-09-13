class UserOpenidsController < ApplicationController
  before_filter :find_user
  
  # GET /user_openids
  # GET /user_openids.xml
  def index
    @user_openids = UserOpenid.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_openids }
    end
  end

  # GET /user_openids/1
  # GET /user_openids/1.xml
  def show
    @user_openid = UserOpenid.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_openid }
    end
  end

  # GET /user_openids/new
  # GET /user_openids/new.xml
  def new
    @user_openid = UserOpenid.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_openid }
    end
  end

  # POST /user_openids
  # POST /user_openids.xml
  def create
    @user_openid = UserOpenid.new(:user_id => @user.id, :openid_url => params[:openid_url])

    respond_to do |format|
      if @user_openid.save
        flash[:notice] = 'OpenID add to your account'
        format.html { redirect_to(edit_user_url(@user)) }
        format.xml  { render :xml => @user_openid, :status => :created, :location => @user_openid }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_openid.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_openids/1
  # DELETE /user_openids/1.xml
  def destroy
    @user_openid = @user.user_openids.find(params[:id])
    if @user_openid.destroy
      flash[:notice] = 'OpenID removed from your account'
    else
      flash[:error] = 'OpenID could not be removed from your account'
    end
    respond_to do |format|
      format.html { redirect_to(edit_user_url(@user)) }
      format.xml  { head :ok }
    end
  end
  
  private
  def find_user
    @user = User.find(params[:user_id])
  end
  
end
