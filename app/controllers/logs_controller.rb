class LogsController < ApplicationController
  around_action :login_from_feed_token, :only => [ :index ]
  before_action :domain_required
  before_action :login_required

  def index
    @game = current_account.games.find(params[:game_id])
    @logs = @game.logs.order('published_at DESC').limit(10).all

    respond_to do |format|
      format.atom
    end
  end
end
