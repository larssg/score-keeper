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
    team_mate = self.memberships.select { |m| m.user_id != user.id }.first.user
  end
  
  def winner?
    self.match.winner == self
  end
  
  def other
    self.match.teams.select { |team| team.id != self.id }.first
  end
  
  def ranking_total
    self.memberships.collect{ |m| m.user.ranking }.sum.to_f
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

    # If match was lost, deduct most points from lead
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
  
  def display_names
    self.memberships.collect { |m| m.user.display_name }
  end
end