class GamesController < ApplicationController
  before_action :domain_required
  before_action :login_required

  def index
    @games = current_account.all_games
  end

  def new
    @game = current_account.games.build
    render :layout => false if pjax?
  end

  def create
    @game = current_account.games.build(params[:game])
    if @game.save
      flash[:notice] = 'Game created.'
      redirect_to games_url
    else
      render :action => 'new'
    end
  end

  def edit
    @game = current_account.games.find(params[:id])
    render :layout => false if pjax?
  end

  def update
    @game = current_account.games.find(params[:id])
    if @game.update_attributes(params[:game])
      flash[:notice] = 'Changes to game saved successfully!'
      redirect_to games_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    game = current_account.games.find(params[:id])
    if current_user.is_account_admin?
      game.destroy
      redirect_to games_url, :notice => 'Game deleted.'
    else
      redirect_to games_url, :notice => 'Only the account administrator can delete games.'
    end
  end

  def game_added_warning
    @game = current_account.games.find(params[:id])
    @latest_membership = current_user.memberships.find(:first, :conditions => ['memberships.game_id = ? AND created_at >= ?', @game.id, 10.minutes.ago], :order => 'created_at DESC')

    if @latest_membership && @latest_membership.team.match.creator != current_user
      render :layout => false
    else
      head :not_found
    end
  end
end
