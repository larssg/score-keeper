class GamesController < ApplicationController
  before_filter :domain_required
  before_filter :login_required

  def index
    @games = current_account.games
  end
  
  def edit
    @game = current_account.games.find(params[:id])
  end
end
