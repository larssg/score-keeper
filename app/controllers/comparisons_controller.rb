class ComparisonsController < ApplicationController
  def index
    @game = params[:game_id].to_i == current_game.id ? current_game : current_account.games.find(params[:game_id])
    @players = @game.game_participations.find(:all, :include => :user, :order => 'users.name').collect { |gp| gp.user }.select { |u| u.enabled? }
    @time_period = params[:period] ? params[:period].to_i : 30

    @selected_player_ids = params[:user] ? params[:user].collect(&:to_i).sort : []
    @selected_players = @selected_player_ids.collect do |sp|
      @players.select do |gp|
        gp.id == sp
      end.first
    end
  end
  
  def show
    @game = params[:game_id].to_i == current_game.id ? current_game : current_account.games.find(params[:game_id])
    @ids = params[:id].split('-').collect(&:to_i).sort
    @time_period = params[:period] ? params[:period].to_i : 30

    respond_to do |format|
      format.chart { render_chart }
    end
  end
  
  protected
  def render_chart
    from = @time_period.days.ago
    players = current_account.users.find(@ids)
    game_participations = @game.game_participations.find(:all, :conditions => { :user_id => @ids})
    memberships = @game.memberships.find(:all,
      :conditions => ['memberships.user_id IN (?) AND memberships.created_at >= ?', @ids, from],
      :order => 'memberships.created_at',
      :select => 'memberships.user_id, memberships.current_ranking, teams.match_id AS match_id, memberships.created_at, matches.played_at AS played_at',
      :joins => 'LEFT JOIN teams ON memberships.team_id = teams.id LEFT JOIN matches ON teams.match_id = matches.id')
    
    data = {}
    memberships.each do |membership|
      match_id = membership.match_id.to_i
      data[match_id] = ['null', 'null', nil] unless data.has_key?(match_id)
      data[match_id][@ids.index(membership.user_id)] = membership.current_ranking
      data[match_id][@ids.size] = membership.played_at.to_time
    end
    
    people = {}
    previous = []
    (0..@ids.size - 1).each do |index|
      people[index] = []
      previous << (game_participations.select { |gp| gp.user_id == @ids[index] }.first).ranking_at(from)
    end

    dates = []
    data.keys.sort.each do |key|
      (0..@ids.size - 1).each do |index|
        ranking = data[key][index]
        if ranking.to_i > 0
          people[index] << ranking
          previous[index] = ranking
        else
          people[index] << previous[index]
        end
      end
      dates << data[key][@ids.size]
    end

    chart = setup_ranking_graph
    (0..@ids.size - 1).each do |index|
      chart.set_data [(game_participations.select { |gp| gp.user_id == @ids[index] }.first).ranking_at(from)] + people[index]
      chart.line 2, colors[index], find_user(@ids[index]).name
    end
    chart.set_x_labels ['Start'[]] + dates.collect { |d| d.to_s :db }

    steps = (data.size / 20).to_i
    chart.set_x_label_style(10, '', 2, steps)
    chart.set_x_axis_steps steps

    render :text => chart.render
  end
end
