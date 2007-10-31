class DashboardController < ApplicationController
  def index
    unless cached?
      @people = Person.find(:all, :order => 'ranking DESC, games_won DESC, last_name')
      @recent_games = Game.find_recent(:limit => 8)
      @games_per_day = Game.count(:group => :played_on, :limit => 10, :order => 'played_on DESC')

      # Sidebar
      @leader = @people[0]
      @game_count = Game.count
      @goals_scored = (Person.sum(:goals_for) + Person.sum(:goals_against)) / 4
      
      # Add game
      if logged_in?
        @person_list = Person.find_all
        @game = Game.new
      end
    end
  end
  
  protected
  def cached?
    read_fragment(dashboard_path) && read_fragment(dashboard_path + '_sidebar') && read_fragment(dashboard_path + '_new_game')
  end
end