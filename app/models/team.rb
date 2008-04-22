class Team < ActiveRecord::Base
  belongs_to :account
  has_many :memberships
  belongs_to :match
  before_save :update_cache_values
  
  def matches_filter(filter)
    if filter.index(',')
      return true if self.team_ids == filter
    else
      return true if self.team_ids.index(filter + ',') || self.team_ids.index(',' + filter)
    end
    false
  end
  
  def team_mate_for(user)
    return nil if self.memberships.size < 2
    team_mate = self.memberships.select { |m| m.user_id != user.id }.first.user
  end
  
  def winner?
    self.match.winner == self
  end
  
  def other
    self.match.teams.select { |team| team.id != self.id }.first
  end
  
  def ranking_total
    self.memberships.collect{ |m| m.game_participation.ranking }.sum.to_f
  end
  
  def self.opponents(team_ids)
    Team.find(:all,
      :conditions => { :team_ids => team_ids },
      :group => 'opponent_ids',
      :select => 'SUM(won) AS wins, COUNT(*) AS matches, opponent_ids AS team_ids')
  end
  
  def self.team_members(user_ids)
    user_ids.split(',').collect { |user_id| user_id.to_i }.sort.collect { |user_id| User.find(user_id) }
  end
  
  def award_points(amount)
    game_participations = self.memberships.collect { |m| m.game_participation }.sort_by(&:ranking)
    
    if game_participations.size == 1
      game_participations.first.update_attribute :ranking, game_participations.first.ranking + amount
      self.memberships.first.update_attribute :current_ranking, game_participations.first.ranking
    else
      award = []
      game_participations.each do |gp|
        award << (amount.abs * (gp.ranking.to_f / ranking_total)).to_i
      end

      # Fix rounding errors
      while award.inject(0) { |sum, item| sum + item } != amount.abs
        if award.inject(0) { |sum, item| sum + item } < amount.abs
          award[-1] += 1
        else
          award[0] -= 1
        end
      end

      # If match was lost, "award" negative points
      award = award.collect { |a| a * -1 } if amount < 0
      
      award = award.reverse if amount < 0
      
      # Award points
      game_participations.each_with_index { |gp, index| gp.ranking += award[index] }
      
      # Save points
      self.memberships.each_with_index do |m, index|
        m.points_awarded = award[index]
        m.current_ranking = game_participations.select { |gp| gp.user_id == m.user_id }.first.ranking
        m.save
      end
      
      # Save game participations
      game_participations.each { |gp| gp.save }
    end
  end
  
  def update_cache_values
    self.team_ids = self.memberships.collect{ |m| m.user_id }.sort.join(',')
  end
  
  def display_names
    self.memberships.collect { |m| m.user.display_name }
  end
end