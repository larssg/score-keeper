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
      format.rss { render :layout => false } # index.rss.builder
      format.xml do
        if params[:person_id]
          render :action => 'person_games'
        else
          render :xml => @games.to_xml
        end
      end
    end
  end
  
  def show
    @game = Game.find(params[:id])
  end
  
  protected
  def load_data_for_index
    if params[:person_id]
      @person = Person.find(params[:person_id])
      @memberships = @person.memberships.find(:all, :order => 'memberships.id DESC', :include => :team)
    else
      conditions = nil
      if params[:filter]
        @filter = Person.find(:all, :conditions => ['id IN (?)', params[:filter].split(',').collect{ |id| id.to_i }], :order => 'display_name, last_name, first_name')
        if params[:filter].index(',')
          conditions = ['team_one = ? OR team_two = ?', params[:filter], params[:filter]]
        else
          conditions = ["team_one LIKE ? OR team_one LIKE ? OR team_two LIKE ? OR team_two LIKE ?", params[:filter] + ',%', '%,' + params[:filter], params[:filter] + ',%', '%,' + params[:filter]]
        end
      end
      @games = Game.paginate_recent(:include => { :teams => { :memberships => :person } }, :conditions => conditions, :page => params[:page])
      @game = current_model.new
      @people = Person.find_all
    end
  end
end