class GamesController < ApplicationController
  before_filter :login_required, :except => :index
  
  make_resourceful do
    publish :xml, :attributes => [ { :teams => [ :score ] } ]
    build :edit, :create, :update

    before :create do
      current_object.creator = current_user
      current_object.played_at ||= 5.minutes.ago

      team_params = [
        {
          :score => params[:teams][:score1],
          :members => [ params[:teams][:person11], params[:teams][:person12] ]
        },
        {
          :score => params[:teams][:score2],
          :members => [ params[:teams][:person21], params[:teams][:person22] ]
        }
      ]
      current_object.teams_from_params(team_params)
    end
    
    response_for :create do
      flash[:notice] = 'Game created.'[]
      redirect_to games_url
    end
  end
  
  def index
    @games = Game.find_recent(:include => { :teams => { :memberships => :person } })
    @game = current_model.new
    @people = Person.find_all
    
    respond_to do |format|
      format.html # index.haml
      format.xml do
        render :xml => @games.to_xml
      end
    end
  end
end