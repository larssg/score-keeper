class TeamsController < ApplicationController
  def index
    unless read_fragment(teams_path)
      @teams = {}
      @team_counts = Team.count(:group => :team_ids).sort_by { |t| t[1] }.reverse
      @team_wins = Team.count(:group => :team_ids, :conditions => { :won => true })

      @team_counts.each do |count|
        @teams[count[0]] = {}
        @teams[count[0]][:team_ids] = count[0]
        @teams[count[0]][:games_played] = count[1]
        @teams[count[0]][:games_won] = 0
        @teams[count[0]][:players] = Person.find(:all, :conditions => { :id => count[0].split(',') })
      end
    
      @team_wins.each do |win|
        @teams[win[0]][:games_won] = win[1]
      end
    
      @teams.keys.each do |team_key|
        @teams[team_key][:percentage] = ((@teams[team_key][:games_won].to_f / @teams[team_key][:games_played].to_f) * 1000).to_i / 10.to_f
      end
    
      @teams.keys.each do |team_key|
        @teams[team_key][:total_ranking] = @teams[team_key][:players].sum(&:ranking)
      end
    
      @teams = @teams.keys.collect { |k| @teams[k] }
      @teams = @teams.sort_by { |t| t[:total_ranking] }.reverse
    end
  end
  
  def show
    @ids = params[:id].split(',').collect { |id| id.to_i }
    respond_to do |format|
      format.html do
        @people = Person.find(:all, :conditions => { :id => @ids }, :limit => 2)
      end
      format.graph { render_chart } 
    end
  end
  
  protected
  def render_chart
    memberships = Membership.find_team(@ids)
    
    data = {}
    memberships.each do |membership|
      game_id = membership.game_id.to_i
      data[game_id] = ['null', 'null', nil] unless data.has_key?(game_id)
      data[game_id][@ids.index(membership.person_id)] = membership.current_ranking
      data[game_id][2] = membership.created_at
    end
    
    person_one = []
    person_two = []
    dates = []
    
    data.keys.sort.each do |key|
      person_one << data[key][0]
      person_two << data[key][1]
      dates << data[key][2]
    end
        
    chart = setup_ranking_graph
    chart.set_data [2000] + person_one
    chart.set_data [2000] + person_two
    chart.line 2, '#3399CC', Person.find(@ids[0]).full_name
    chart.line 2, '#77BBDD', Person.find(@ids[1]).full_name
    chart.set_x_labels ['Start'[]] + dates.collect { |d| d.to_s :db }

    steps = (data.size / 20).to_i
    chart.set_x_label_style(10, '', 2, steps)
    chart.set_x_axis_steps steps

    render :text => chart.render
  end
end