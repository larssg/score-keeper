class Account < ActiveRecord::Base
  has_many :games
  has_many :teams
  has_many :users
  
  validates_presence_of :name
  validates_uniqueness_of :domain
  validates_format_of :domain, :with => /^[0-9a-z]+$/, :on => :create, :message => "can only contain alphanumeric lowercase characters"

  def all_users
    @all_users ||= self.users.find(:all, :order => 'name, display_name')
  end
  
  def user_ids
    @users_ids ||= self.all_users.collect { |u| u.id }
  end
end