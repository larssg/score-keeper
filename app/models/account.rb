class Account < ActiveRecord::Base
  has_many :games
  has_many :teams
  has_many :users
  
  validates_presence_of :name
  validates_uniqueness_of :domain
  validates_format_of :domain, :with => /^[0-9a-z]+$/, :on => :create, :message => "can only contain alphanumeric lowercase characters"
  validates_exclusion_of :domain, :in => %w(www pop pop3 imap smtp mail support ftp mysql), :on => :create, :message => "is not allowed"

  def all_users
    @all_users ||= self.users.find(:all, :order => 'name, display_name')
  end
  
  def user_ids
    @users_ids ||= self.all_users.collect { |u| u.id }
  end
end