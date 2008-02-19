class DashboardController < ApplicationController
  before_filter :login_required

  def index
    @recent_games = Game.find_recent(:limit => 10, :include => { :teams => :memberships })

    unless cached?
      @rankings = User.find_ranked
      @newbies = User.find_newbies
      @games_per_day = Game.count(:group => :played_on, :limit => 10, :order => 'games.played_on DESC')

      # Sidebar
      @leader = @rankings.size > 0 ? @rankings[0] : @newbies[0]
      @game_count = Game.count
      @goals_scored = Game.goals_scored
      @all_time_high = Membership.all_time_high
      @all_time_low = Membership.all_time_low
    end

    # Add game
    if logged_in?
      @game = Game.new
    end
  end
  
  protected
  def cached?
    read_fragment(root_path) && read_fragment(root_path + '_sidebar')
  end
end