class GamesController < ApplicationController
  before_filter :login_required
  cache_sweeper :game_sweeper
  
  make_resourceful do
    publish :xml, :json, :csv, :attributes => [ { :teams => [ :score ] } ]
    build :edit, :create, :update, :destroy

    before :create do
      current_object.attributes = params[:game]
      current_object.creator = current_user
    end
    
    response_for :create do
      flash[:notice] = 'Game created.'[]
      redirect_back_or_default root_url
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
        if params[:user_id]
          @memberships = @user.memberships.find(:all, :order => 'memberships.id DESC', :include => :team)
          render :action => 'user_games'
        else
          render :xml => @games.to_xml
        end
      end
      format.graph do
        render_chart if params[:user_id]
      end
    end
  end
  
  def show
    @game = Game.find(params[:id])
    @comments = @game.comments.find(:all, :order => 'created_at')
    @comment = @game.comments.build
  end
  
  protected
  def load_data_for_index
    if params[:user_id]
      @user = User.find(params[:user_id])
    else
      conditions = nil
      if params[:filter]
        @filter = User.find(:all, :conditions => ['id IN (?)', params[:filter].split(',').collect{ |id| id.to_i }], :order => 'display_name, name')
        if params[:filter].index(',')
          conditions = ['team_one = ? OR team_two = ?', params[:filter], params[:filter]]
        else
          conditions = ["team_one LIKE ? OR team_one LIKE ? OR team_two LIKE ? OR team_two LIKE ?", params[:filter] + ',%', '%,' + params[:filter], params[:filter] + ',%', '%,' + params[:filter]]
        end
      end
      @games = Game.paginate_recent(:include => { :teams => { :memberships => :user } }, :conditions => conditions, :page => params[:page])
      @game = current_model.new
    end
  end
  
  def render_chart
    chart = setup_ranking_graph
    
    memberships = @user.memberships.find(:all, :order => 'memberships.id', :select => 'memberships.current_ranking, memberships.created_at, games.played_at AS played_at', :joins => 'LEFT JOIN teams ON memberships.team_id = teams.id LEFT JOIN games ON teams.game_id = games.id')
    chart.set_data [2000] + memberships.collect { |m| m.current_ranking }
    chart.set_x_labels ['Start'[]] + memberships.collect { |m| m.played_at.to_time.to_s :db }
    chart.line 2, '#3399CC'

    steps = (memberships.size / 20).to_i
    chart.set_x_label_style(10, '', 2, steps)
    chart.set_x_axis_steps steps

    render :text => chart.render
  end
end