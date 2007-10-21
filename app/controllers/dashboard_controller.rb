class DashboardController < ApplicationController
  def index
    unless read_fragment(dashboard_path)
      @people = Person.find(:all, :order => 'ranking DESC, games_won DESC, last_name')
      @recent_games = Game.find_recent(:limit => 5)
    end
    unless read_fragment(dashboard_path + '_sidebar')
      @game_count = Game.count
      @goals_scored = (Person.sum(:goals_for) + Person.sum(:goals_against)) / 4
    end
  end
end