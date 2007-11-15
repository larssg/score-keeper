class Membership < ActiveRecord::Base
  belongs_to :team
  belongs_to :person

  def self.all_time_high
    Membership.find(:first, :order => 'memberships.current_ranking DESC')
  end
  
  def self.all_time_low
    Membership.find(:first, :order => 'memberships.current_ranking')
  end
end