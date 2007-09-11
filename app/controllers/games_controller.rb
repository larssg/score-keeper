class GamesController < ApplicationController
  before_filter :login_required

  make_resourceful do
    build :edit, :create, :update

    before :create do
      current_object.creator = current_user
      current_object.played_at ||= 5.minutes.ago
    
      team_one = current_object.teams.create(:score => params[:teams][:score1])
      team_one.memberships.create(:person_id => params[:teams][:person11])
      team_one.memberships.create(:person_id => params[:teams][:person12])
      
      team_two = current_object.teams.create(:score => params[:teams][:score2])
      team_two.memberships.create(:person_id => params[:teams][:person21])
      team_two.memberships.create(:person_id => params[:teams][:person22])
    end
    
    response_for :create do
      flash[:notice] = 'Game created.'[]
      redirect_to games_url
    end
  end
  
  def index
    @games = Game.find_recent
    @game = current_model.new
    @people = Person.find_all
  end
end