class MatchesController < ApplicationController
  around_filter :login_from_feed_token, :only => [ :index ]
  before_filter :domain_required
  before_filter :login_required

  def index
    if params[:user_id]
      # used for /users/xxx/matches.graph
      @user = current_account.users.find(params[:user_id])
    else
      @matches = current_game.matches.paginate(
          Match.recent_options(
                               params[:filter],
                               :game => current_game,
                               :include => { :teams => :memberships },
                               :page => params[:page]))
      @filter = current_account.matches.find_filter_users(params[:filter])
      @game = current_game
    end

    respond_to do |format|
      format.html # index.haml
      format.atom { render :layout => false } # index.atom.builder
    end
  end

  def show
    @match = current_account.matches.find(params[:id])
    @comments = @match.comments.find(:all, :order => 'created_at')
    @comment = @match.comments.build
  end

  def new
    @match = current_account.matches.build
  end

  def create
    @match = current_account.matches.build(params[:match])
    @match.game_id = params[:game_id]
    @match.creator = current_user
    if @match.save
      flash[:notice] = 'Match added successfully.'
      redirect_back_or_default root_url
    else
      flash[:warning] = 'The match could not be saved. Please try again.'
      redirect_back_or_default root_url
    end
  end

  def edit
    @match = current_account.matches.find(params[:id])
  end

  def update
    @match = current_account.matches.find(params[:id])
    if @match.update_attributes(params[:match])
      flash[:notice] = 'Match updated.'
      redirect_to matches_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @match = current_account.matches.find_by_id(params[:id])
    if !@match.nil? && @match.destroy
      flash[:notice] = 'Match deleted.'
      redirect_back_or_default game_matches_url(@match.game_id)
    else
      flash[:warning] = 'Unable to delete match.'
      redirect_back_or_default game_matches_url(params[:game_id])
    end
  end
end
