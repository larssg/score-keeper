# frozen_string_literal: true
class ComparisonsController < ApplicationController
  before_filter :login_required

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

    @indexed_sorted_players = []
    @selected_players.each_with_index do |player, index|
      @indexed_sorted_players << [player, index]
    end
    @indexed_sorted_players = @indexed_sorted_players.sort_by { |ip| ip.first.name }

    @json = chart_json(@game, @selected_player_ids, @time_period)
  end

  protected
  def chart_json(game, user_ids, time_period)
    from = time_period.days.ago
    players = current_account.users.find(user_ids)
    game_participations = game.game_participations.find(:all, :conditions => { :user_id => user_ids})
    memberships = game.memberships.find(:all,
                                         :conditions => ['memberships.user_id IN (?) AND memberships.created_at >= ?', user_ids, from],
                                         :order => 'memberships.created_at',
                                         :select => 'memberships.user_id, memberships.current_ranking, teams.match_id AS match_id, memberships.created_at, matches.played_at AS played_at',
                                         :joins => 'LEFT JOIN teams ON memberships.team_id = teams.id LEFT JOIN matches ON teams.match_id = matches.id')

    data = {}
    memberships.each do |membership|
      match_id = membership.match_id.to_i
      data[match_id] = ['null', 'null', nil] unless data.has_key?(match_id)
      data[match_id][user_ids.index(membership.user_id)] = membership.current_ranking
      data[match_id][user_ids.size] = membership.played_at.to_time
    end

    people = {}
    previous = []
    (0..user_ids.size - 1).each do |index|
      people[index] = []
      previous << (game_participations.select { |gp| gp.user_id == user_ids[index] }.first).ranking_at(from)
    end

    dates = []
    data.keys.sort.each do |key|
      (0..user_ids.size - 1).each do |index|
        ranking = data[key][index]
        if ranking.to_i > 0
          people[index] << ranking
          previous[index] = ranking
        else
          people[index] << previous[index]
        end
      end
      dates << data[key][user_ids.size]
    end

    elements = []
    user_ids.each_with_index do |user_id, index|
      values = [(game_participations.select { |gp| gp.user_id == user_id }.first).ranking_at(from)] + people[index]
      user_name = find_user(user_id).name
      elements << {
        :type => 'line',
        :text => user_name,
        :colour => colors[index],
        'dot-style' => {
          'dot-size' => 4,
          :tip => "#{user_name}<br>#val# at #x_label#",
          :type => 'dot'
        },
        :values => values
      }
    end

    x_labels = ['Start'] + dates.collect { |d| d.to_s :db }

    steps = (data.size / 20).to_i

    {
      :elements => elements,
      :y_legend => {
        :text => 'Ranking',
        :style => '{color: #000000; font-size: 12px}'
      },
      :y_axis => {
        :min => current_game.y_min,
        :max => current_game.y_max,
        :steps => 100,
        :colour => '#808080',
        'grid-colour' => '#dddddd'
      },
      :x_axis => {
        :steps => steps,
        :labels => {
          :labels => x_labels,
          :steps => steps,
          :rotate => 315
        },
        :colour => '#808080',
        'grid-colour' => '#dddddd'
      },
      :bg_colour => '#ffffff',
      :tooltip => {
        :shadow => false,
        :body => "{font-size: 10px; font-weight: normal; color: #000000;}",
        :title => "{font-size: 14px; color: #000;}",
        :background => "#ffffff",
        :colour => "#3399cc",
        :stroke => 3
      }
    }.to_json
  end
end
