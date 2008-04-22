class TeamsController < ApplicationController
  before_filter :domain_required
  before_filter :login_required

  def index
    unless read_fragment(cache_key)
      @teams = {}
      @team_counts = current_account.teams.count(
        :group => :team_ids,
        :conditions => ['matches.game_id = ?', current_game.id],
        :joins => 'LEFT JOIN matches ON teams.match_id = matches.id').sort_by { |t| t[1] }.reverse
      @team_wins = current_account.teams.count(
        :group => :team_ids,
        :conditions => ['matches.game_id = ? AND teams.won = ?', current_game.id, true],
        :joins => 'LEFT JOIN matches ON teams.match_id = matches.id')

      # Find user IDs
      @users = {}
      @team_counts.each do |count|
        count[0].split(',').collect(&:to_i).each { |user_id| @users[user_id] = true }
      end
      @game_participations = current_game.game_participations.find_all_by_user_id(@users.keys)

      @team_counts.each do |count|
        @teams[count[0]] = {}
        @teams[count[0]][:team_ids] = count[0]
        @teams[count[0]][:matches_played] = count[1]
        @teams[count[0]][:matches_won] = 0
        @teams[count[0]][:players] = count[0].split(',').collect { |id| find_user(id) }
      end
    
      @team_wins.each do |win|
        @teams[win[0]][:matches_won] = win[1]
      end
    
      @teams.keys.each do |team_key|
        @teams[team_key][:percentage] = ((@teams[team_key][:matches_won].to_f / @teams[team_key][:matches_played].to_f) * 1000).to_i / 10.to_f
      end
    
      @teams.keys.each do |team_key|
        @teams[team_key][:total_ranking] = @teams[team_key][:players].sum { |user| @game_participations.select { |gp| gp.user_id == user.id }.first.ranking }
      end
    
      @teams = @teams.keys.collect { |k| @teams[k] }
      @teams = @teams.sort_by { |t| t[:total_ranking] }.reverse
    end
  end
  
  def show
    @time_period = params[:period] ? params[:period].to_i : 30
    @ids = params[:id].split(',').collect { |id| id.to_i }.sort
    respond_to do |format|
      format.html do
        @team_members = current_account.users.find(:all, :conditions => { :id => @ids }, :limit => 2)
        @opponents = current_account.teams.opponents(@ids.join(','))
      end
      format.graph { render_chart } 
    end
  end
  
  protected
  def render_chart
    from = @time_period.days.ago
    memberships = Membership.find_team(@ids, from, current_account)
    game_participations = current_game.game_participations.find_all_by_user_id(@ids)
    
    data = {}
    memberships.each do |membership|
      match_id = membership.match_id.to_i
      data[match_id] = ['null', 'null', nil] unless data.has_key?(match_id)
      data[match_id][@ids.index(membership.user_id)] = membership.current_ranking
      data[match_id][2] = membership.played_at.to_time
    end
    
    people = {}
    previous = []
    (0..1).each do |index|
      people[index] = []
      previous << (game_participations.select { |gp| gp.user_id == @ids[index] }.first).ranking_at(from)
    end
    dates = []
    
    data.keys.sort.each do |key|
      (0..1).each do |index|
        ranking = data[key][index]
        if ranking.to_i > 0
          people[index] << ranking
          previous[index] = ranking
        else
          people[index] << previous[index]
        end
      end
      dates << data[key][2]
    end

    chart = setup_ranking_graph
    (0..1).each do |index|
      chart.set_data [(game_participations.select { |gp| gp.user_id == @ids[index] }.first).ranking_at(from)] + people[index]
    end
    chart.line 2, '#3399CC', find_user(@ids[0]).name
    chart.line 2, '#77BBDD', find_user(@ids[1]).name
    chart.set_x_labels ['Start'[]] + dates.collect { |d| d.to_s :db }

    steps = (data.size / 20).to_i
    chart.set_x_label_style(10, '', 2, steps)
    chart.set_x_axis_steps steps

    render :text => chart.render
  end
end
