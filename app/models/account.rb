class Account < ActiveRecord::Base
  has_many :games
  has_many :matches
  has_many :teams
  has_many :users
  has_many :logs

  validates :name, :time_zone, presence: true
  validates :domain, uniqueness: true
  validates :domain, format: { :with => /^[0-9a-z]+$/, :on => :create, :message => "can only contain alphanumeric lowercase characters" }
  validates :domain, exclusion: { :in => %w(www pop pop3 imap smtp mail support ftp mysql), :on => :create, :message => "is not allowed" }

  before_validation :set_name_from_domain

  attr_accessible :name, :domain, :time_zone

  def all_users
    @all_users ||= self.users.all
  end

  def all_games
    @all_games ||= self.games.all
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
