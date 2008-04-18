class GamesController < ApplicationController
  def index
    @games = current_account.games
  end
  
  def edit
    @game = current_account.games.find(params[:id])
  end
end
