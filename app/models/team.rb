# frozen_string_literal: true

class Team < ActiveRecord::Base
  belongs_to :account
  has_many :memberships
  belongs_to :match
  before_save :update_cache_values

  def matches_filter(filter)
    if filter.index(',')
      return true if team_ids == filter
    else
      if team_ids.index(filter + ',') || team_ids.index(',' + filter)
        return true
      end
    end
    false
  end

  def team_mate_for(user)
    return nil if memberships.size < 2

    team_mate = memberships.reject { |m| m.user_id == user.id }.first.user
  end

  def winner?
    match.winner == self
  end

  def other
    match.teams.reject { |team| team.id == id }.first
  end

  def ranking_total
    memberships.collect { |m| m.game_participation.ranking }.sum.to_f
  end

  def self.opponents(team_ids)
    where(team_ids: team_ids).group(:opponent_ids).select('SUM(won) AS wins, COUNT(*) AS matches, opponent_ids AS team_ids')
  end

  def self.team_members(user_ids)
    user_ids.split(',').collect(&:to_i).sort.collect { |user_id| User.find(user_id) }
  end

  def award_points(amount)
    game_participations = GameParticipation.find(:all,
                                                 conditions: {
                                                   game_id: memberships.first.game_id,
                                                   user_id: memberships.collect(&:user_id)
                                                 }).sort_by(&:ranking)
    award = Team.split_award_points(amount, game_participations.collect(&:ranking))

    # Award and save points
    game_participations.each_with_index do |gp, index|
      gp.ranking += award[index]
      gp.save

      membership = memberships.select { |m| m.user_id == gp.user_id }.first
      membership.points_awarded = award[index]
      membership.current_ranking = gp.ranking
      membership.save
    end
  end

  # The rankings parameter must be sorted in ascending order
  def self.split_award_points(amount, rankings)
    return [amount] if rankings.size == 1

    throw 'Rankings not sorted properly' unless rankings == rankings.sort

    award = rankings.collect do |ranking|
      (amount * (ranking.to_f / rankings.sum.to_f)).to_i
    end

    # Fix rounding errors
    award[-1] += amount - award.sum

    # If match was won, reverse the award list
    amount > 0 ? award.reverse : award
  end

  def update_cache_values
    self.team_ids = memberships.collect(&:user_id).sort.join(',')
  end

  def display_names
    memberships.collect { |m| m.user.display_name }
  end
end
