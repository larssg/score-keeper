class Account < ActiveRecord::Base
  has_many :games
  has_many :teams
  has_many :users

  def all_users
    @all_users ||= self.users.find(:all, :order => 'name, display_name')
  end
  
  def user_ids
    @users_ids ||= self.all_users.collect { |u| u.id }
  end
end
