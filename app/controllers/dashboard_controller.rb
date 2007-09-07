class DashboardController < ApplicationController
  def index
    @people = Person.find(:all, :order => 'games_won DESC')
  end
end