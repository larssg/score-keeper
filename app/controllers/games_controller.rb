class GamesController < ApplicationController
  before_filter :login_required, :except => :index
  cache_sweeper :game_sweeper
  
  make_resourceful do
    publish :xml, :json, :csv, :attributes => [ { :teams => [ :score ] } ]
    build :edit, :create, :update, :destroy

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
    
    response_for :create_fails do
      load_data_for_index
      render :action => 'index'
    end
  end
  
  def index
    load_data_for_index
    
    respond_to do |format|
      format.html # index.haml
      format.atom { render :layout => false } # index.atom.builder
      format.xml  { render :xml => @games.to_xml }
    end
  end
  
  protected
  def load_data_for_index
    @games = Game.paginate_recent(:include => { :teams => { :memberships => :person } }, :page => params[:page])
    @game = current_model.new
    @people = Person.find_all
  end
end