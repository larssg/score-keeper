require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  belongs_to :account
  has_many :game_participations
  has_many :games, :through => :game_participations
  has_many :memberships
  has_many :comments
  has_many :logs
  has_many :teams, :through => :memberships
  belongs_to :last_game, :class_name => "Game", :foreign_key => "last_game_id"

  validates_presence_of     :email
  validates_length_of       :email,    :within => 3..100
  validates_presence_of     :login
  validates_length_of       :login,    :within => 2..100
  validates_uniqueness_of   :login,    :scope => :account_id, :case_sensitive => false, :message => 'is already taken; sorry!'
  validates_uniqueness_of   :email,    :scope => :account_id, :case_sensitive => false, :message => 'is already being used; do you already have an account?'

  validates_presence_of     :password,                    :if => :password_required?
  validates_presence_of     :password_confirmation,       :if => :password_required?
  validates_length_of       :password, :within => 4..40,  :if => :password_required?
  validates_confirmation_of :password,                    :if => :password_required?

  validates_presence_of :name
  validates_presence_of :time_zone

  before_save :encrypt_password
  before_save :set_display_name
  before_validation :set_time_zone
  before_validation :set_name_from_login
  after_create :set_feed_token
  before_destroy :remove_matches

  default_scope order('name, display_name')

  has_attached_file :avatar, :styles => { :thumb => '60x60>' }

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :name, :display_name, :time_zone, :avatar

  def set_display_name
    return if name.blank?
    self.display_name = name.split[0] if display_name.blank?
  end

  def all_time_high(game)
    Membership.find(:first, :conditions => { :user_id => id, :game_id => game.id }, :order => 'memberships.current_ranking DESC')
  end

  def all_time_low(game)
    Membership.find(:first, :conditions => { :user_id => id, :game_id => game.id }, :order => 'memberships.current_ranking')
  end

  def position(game)
    game.user_positions.each_with_index do |game_participation, index|
      return index + 1 if game_participation.user_id == id
    end
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def set_time_zone
    if time_zone.blank?
      self.time_zone = account.time_zone unless account.nil?
      self.time_zone ||= 'Copenhagen'
    end
  end

  def set_feed_token
    update_attribute :feed_token, encrypt("#{email}--#{5.minutes.ago}")
  end

  def set_login_token
    update_attribute :login_token, encrypt("#{email}--#{5.minutes.ago}")
  end

  protected

  def set_name_from_login
    self.name ||= login.humanize
  end

  def remove_matches
    memberships.each do |membership|
      match = membership.team.match
      match.postpone_ranking_update = true
      match.destroy
    end

    # Fix stats
    account.games.each do |game|
      Match.reset_rankings(game)
    end
  end

  # before filter
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end
end
