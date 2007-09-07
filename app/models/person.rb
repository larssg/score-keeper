# == Schema Information
# Schema version: 5
#
# Table name: people
#
#  id         :integer       not null, primary key
#  name       :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

class Person < ActiveRecord::Base
  has_many :memberships

  def initials
    self.full_name.split(' ').collect{ |n| n.first }.join
  end
  
  def full_name
    [self.first_name, self.last_name].join(' ')
  end

  def self.find_all
    find(:all, :order => 'display_name, last_name, first_name')
  end

  def winning_percentage
    return 0.0 if memberships_count == 0
    ((games_won.to_f / memberships_count.to_f) * 1000).to_i / 10.to_f
  end
  
  def difference
    goals_for - goals_against
  end
  
  def difference_average
    return 0.0 if memberships_count == 0
    ((10 * difference) / memberships_count) / 10.0
  end
end