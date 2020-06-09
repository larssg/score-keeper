class TeamsController < ApplicationController
  before_action :domain_required
  before_action :login_required

  def index
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

  def show
    @time_period = params[:period] ? params[:period].to_i : 30
    @ids = params[:id].split(',').collect(&:to_i).sort
    @team_members = current_account.users.where(:id => @ids).limit(2)
    @opponents = current_account.teams.opponents(@ids.join(',')).all
  end
end
