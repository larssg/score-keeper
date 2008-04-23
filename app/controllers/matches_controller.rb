class MatchesController < ApplicationController
  around_filter :login_from_feed_token, :only => [ :index ]
  before_filter :domain_required
  before_filter :login_required
  
  def index
    if params[:user_id] 
      # used for /users/xxx/matches.graph
      @user = current_account.users.find(params[:user_id])
    else
      @matches = current_game.matches.paginate(
        Match.recent_options(params[:filter],
          :include => { :teams => :memberships }, 
          :page => params[:page]))
      @filter = current_account.matches.find_filter_users(params[:filter])
    end
    
    respond_to do |format|
      format.html # index.haml
      format.atom { render :layout => false } # index.atom.builder
      format.graph { render_chart if params[:user_id] }
    end
  end
  
  def show
    @match = current_account.matches.find(params[:id])
    @comments = @match.comments.find(:all, :order => 'created_at')
    @comment = @match.comments.build
  end
  
  def new
    @match = current_account.matches.build
  end
  
  def create
    @match = current_account.matches.build(params[:match])
    @match.game_id = params[:game_id]
    @match.creator = current_user
    if @match.save
      flash[:notice] = 'Match added successfully.'[]
      redirect_back_or_default root_url
    else
      flash[:warning] = 'The match could not be saved. Please try again.'[]
      redirect_back_or_default root_url
    end
  end
  
  def edit
    @match = current_account.matches.find(params[:id])
  end
  
  def update
    @match = current_account.matches.find(params[:id])
    if @match.update_attributes(params[:match])
      flash[:notice] = 'Match updated.'[]
      redirect_to matches_url
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @match = current_account.matches.find(params[:id])
    if !@match.nil? && @match.destroy
      flash[:notice] = 'Match deleted.'[]
      redirect_back_or_default matches_url
    else
      flash[:notice] = 'Unable to delete match.'[]
      redirect_back_or_default matches_url
    end
  end
  
  protected
  def render_chart
    time_period = params[:period].to_i
    from = time_period.days.ago
    chart = setup_ranking_graph

    game_participation = current_game.game_participations.find_by_user_id(@user.id)
    memberships = game_participation.memberships.find(:all,
      :conditions => ['matches.played_at >= ?', from],
      :order => 'memberships.id',
      :select => 'memberships.current_ranking, memberships.created_at, matches.played_at AS played_at',
      :joins => 'LEFT JOIN teams ON memberships.team_id = teams.id LEFT JOIN matches ON teams.match_id = matches.id')
    chart.set_data [game_participation.ranking_at(from)] + memberships.collect { |m| m.current_ranking }
    chart.set_x_labels ['Start'[]] + memberships.collect { |m| m.played_at.to_time.to_s :db }
    chart.line 2, '#3399CC'

    steps = (memberships.size / 20).to_i
    chart.set_x_label_style(10, '', 2, steps)
    chart.set_x_axis_steps steps

    render :text => chart.render
  end
end