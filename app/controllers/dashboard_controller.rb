class DashboardController < ApplicationController
  def index
    @people = Person.find(:all, :order => 'games_won DESC').sort_by(&:winning_percentage).reverse
    @game_count = Game.count
  end
end