# == Schema Information
# Schema version: 8
#
# Table name: memberships
#
#  id         :integer(11)   not null, primary key
#  person_id  :integer(11)   
#  team_id    :integer(11)   
#  created_at :datetime      
#  updated_at :datetime      
#

# == Schema Information
# Schema version: 5
#
# Table name: memberships
#
#  id         :integer       not null, primary key
#  person_id  :integer       
#  team_id    :integer       
#  created_at :datetime      
#  updated_at :datetime      
#

class Membership < ActiveRecord::Base
  belongs_to :team
  belongs_to :person, :counter_cache => true
end
