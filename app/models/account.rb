class Account < ActiveRecord::Base
  has_many :games
  has_many :matches
  has_many :teams
  has_many :users
  has_many :logs
  
  validates_presence_of :name, :time_zone
  validates_uniqueness_of :domain
  validates_format_of :domain, :with => /^[0-9a-z]+$/, :on => :create, :message => "can only contain alphanumeric lowercase characters"
  validates_exclusion_of :domain, :in => %w(www pop pop3 imap smtp mail support ftp mysql), :on => :create, :message => "is not allowed"
  
  before_validation :set_name_from_domain
  
  attr_accessible :name, :domain, :time_zone

  def all_users
    @all_users ||= self.users.find(:all, :order => 'name, display_name')
  end
  
  def all_games
    @all_games ||= self.games.find(:all, :order => 'name')
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
  
  def reset_positions!
    @ranked_users = nil
    @user_positions = nil
  end
  
  protected
  def set_name_from_domain
    self.name ||= self.domain.humanize
  end
end