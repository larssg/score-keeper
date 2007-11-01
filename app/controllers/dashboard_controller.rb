class DashboardController < ApplicationController
  def index
    unless cached?
      @rankings = Person.find(:all, :order => 'ranking DESC, games_won DESC, last_name', :conditions => 'memberships_count >= 20')
      @newbies = Person.find(:all, :order => 'memberships_count DESC, ranking DESC, games_won DESC, last_name', :conditions => 'memberships_count < 20')
      @recent_games = Game.find_recent(:limit => 8)
      @games_per_day = Game.count(:group => :played_on, :limit => 10, :order => 'played_on DESC')

      # Sidebar
      @leader = @rankings.size > 0 ? @rankings[0] : @newbies[0]
      @game_count = Game.count
      @goals_scored = Person.sum(:goals_for) / 2
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