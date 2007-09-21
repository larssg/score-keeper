class Team < ActiveRecord::Base
  has_many :memberships
  belongs_to :game
  before_save :update_cache_values
  
  def other
    self.game.teams.select { |team| team.id != self.id }.first
  end
  
  def ranking_total
    self.memberships.collect{ |m| m.person.ranking }.sum.to_f
  end
  
  def award_points(amount)
    members = self.memberships.collect { |m| m.person }
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
    
    self.memberships.select{ |m| m.person == lead }.first.update_attribute :points_awarded, award_to_lead
    self.memberships.select{ |m| m.person == trail }.first.update_attribute :points_awarded, award_to_trail
    
    lead.save
    trail.save
  end
  
  def update_cache_values
    self.team_ids = self.memberships.collect{ |m| m.person_id }.sort.join(',')
  end
end