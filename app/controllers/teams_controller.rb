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
    respond_to do |format|
      format.html do
        @people = Person.find(:all, :conditions => { :id => params[:id].split(',') }, :limit => 2)
      end
      format.graph do
      end
    end
  end
end