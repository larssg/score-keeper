class Account < ActiveRecord::Base
  has_many :games
  has_many :teams
  has_many :users
  
  def user_ids
    @users_ids ||= self.users.collect { |u| u.id }
  end
end
