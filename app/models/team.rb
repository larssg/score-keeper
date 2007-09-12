class Team < ActiveRecord::Base
  has_many :memberships
  belongs_to :game
  
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

    award_to_lead = (amount.abs * (lead.ranking.to_f / self.ranking_total.to_f)).to_i
    award_to_trail = (amount.abs * (trail.ranking.to_f / self.ranking_total.to_f)).to_i
    
    # Fix rounding errors
    if award_to_lead + award_to_trail < amount.abs
      award_to_trail += 1
    elsif award_to_lead + award_to_trail > amount.abs
      award_to_lead -= 1
    end
    
    if amount < 0
      # Deduct most points from lead
      lead.ranking -= award_to_lead
      trail.ranking -= award_to_trail
    else
      # Award most points to trail
      lead.ranking += award_to_trail
      trail.ranking += award_to_lead
    end
    
    lead.save
    trail.save
  end
end