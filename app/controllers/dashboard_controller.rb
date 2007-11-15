class DashboardController < ApplicationController
  def index
    unless cached?
      @rankings = Person.find_ranked
      @newbies = Person.find_newbies
      @recent_games = Game.find_recent(:limit => 8)
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
      @person_list = Person.find_all
      @game = Game.new
    end
  end
  
  protected
  def cached?
    read_fragment(dashboard_path) && read_fragment(dashboard_path + '_sidebar')
  end
end