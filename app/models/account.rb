class Account < ActiveRecord::Base
  has_many :matches
  has_many :teams
  has_many :users
  has_many :logs
  
  validates_presence_of :name
  validates_uniqueness_of :domain
  validates_format_of :domain, :with => /^[0-9a-z]+$/, :on => :create, :message => "can only contain alphanumeric lowercase characters"
  validates_exclusion_of :domain, :in => %w(www pop pop3 imap smtp mail support ftp mysql), :on => :create, :message => "is not allowed"
  validates_numericality_of :newbie_limit, :greater_than_or_equal_to => 0

  def all_users
    @all_users ||= self.users.find(:all, :order => 'name, display_name')
  end
  
  def enabled_users
    @enabled_users ||= all_users.select { |u| u.enabled? }
  end
  
  def user_ids
    @users_ids ||= self.all_users.collect { |u| u.id }
  end

  def enabled_user_ids
    @enabled_user_ids ||= self.enabled_users.collect { |u| u.id }
  end
  
  def ranked_users
    self.users.find(:all, :order => 'ranking DESC, matches_won DESC, name', :conditions => ['enabled = ? AND memberships_count >= ?', true, self.newbie_limit])
  end
  
  def newbie_users
    self.users.find(:all, :order => 'memberships_count DESC, ranking DESC, matches_won DESC, name', :conditions => ['enabled = ? AND memberships_count < ?', true, self.newbie_limit])
  end  
end