class DashboardController < ApplicationController
  def index
    unless read_fragment(dashboard_path)
      @people = Person.find(:all, :order => 'ranking DESC, games_won DESC, last_name')
      @game_count = Game.count
    end
  end
end