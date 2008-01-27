class Team < ActiveRecord::Base
  has_many :memberships
  belongs_to :game
  before_save :update_cache_values
  before_save :update_team_cache_on_game
  
  def winner?
    self.game.winner == self
  end
  
  def other
    self.game.teams.select { |team| team.id != self.id }.first
  end
  
  def ranking_total
    self.memberships.collect{ |m| m.user.ranking }.sum.to_f
  end
  
  def award_points(amount)
    members = self.memberships.collect { |m| m.user }
    lead = members.first.ranking > members.last.ranking ? members.first : members.last
    trail = lead == members.first ? members.last : members.first

    award_to_lead = (amount.abs * (trail.ranking.to_f / self.ranking_total.to_f)).to_i
    award_to_trail = (amount.abs * (lead.ranking.to_f / self.ranking_total.to_f)).to_i
    
    # Fix rounding errors
    if award_to_lead + award_to_trail < amount.abs
      award_to_trail += 1
    elsif award_to_lead + award_to_trail > amount.abs
      award_to_lead -= 1
    end

    # If game was lost, deduct most points from lead
    if amount < 0
      temp = award_to_lead
      award_to_lead = award_to_trail
      award_to_trail = temp
      
      award_to_lead *= -1
      award_to_trail *= -1
    end
    
    # Award most points to trail
    lead.ranking += award_to_lead
    trail.ranking += award_to_trail

    # Save points
    lead_membership = self.memberships.select{ |m| m.user == lead }.first
    lead_membership.points_awarded = award_to_lead
    lead_membership.current_ranking = lead.ranking
    lead_membership.save
    
    lead_membership = self.memberships.select{ |m| m.user == trail }.first
    lead_membership.points_awarded = award_to_trail
    lead_membership.current_ranking = trail.ranking
    lead_membership.save
    
    lead.save
    trail.save
  end
  
  def update_cache_values
    self.team_ids = self.memberships.collect{ |m| m.user_id }.sort.join(',')
  end
  
  def update_team_cache_on_game
    if self.game.teams.count == 2
      self.game.team_one = self.game.teams.first.team_ids
      self.game.team_two = self.game.teams.last.team_ids
      self.game.save
    end
  end
  
  def display_names
    self.memberships.collect { |m| m.user.display_name }
  end
end