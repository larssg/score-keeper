require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  
  belongs_to :account
  has_many :memberships
  has_many :comments
  belongs_to :mugshot
  has_many :logs
  
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
  validates_presence_of :display_name
  
  before_save :encrypt_password
  after_create :set_feed_token
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :name, :display_name
  
  before_destroy :remove_matches

  def self.find_all
    find(:all, :order => 'name, display_name')
  end
  
  def matches_lost
    memberships_count - matches_won
  end

  def winning_percentage
    return 0.0 if memberships_count == 0
    ((matches_won.to_f / memberships_count.to_f) * 1000).to_i / 10.to_f
  end
  
  def difference
    goals_for - goals_against
  end
  
  def difference_average
    return 0.0 if memberships_count == 0
    ((10 * difference) / memberships_count) / 10.0
  end

  def all_time_high
    Membership.find(:first, :conditions => { :user_id => self.id }, :order => 'memberships.current_ranking DESC')
  end
  
  def all_time_low
    Membership.find(:first, :conditions => { :user_id => self.id }, :order => 'memberships.current_ranking')
  end
  
  def position
    ranked = self.account.ranked_users
    ranked.each_with_index do |user, index|
      return index + 1 if user.id == self.id
    end
    
    newbies = self.account.newbie_users
    newbies.each_with_index do |user, index|
      return index + 1 + ranked.size if user.id == self.id
    end
  end
  
  def ranking_at(time)
    membership = self.memberships.find(:first,
      :conditions => [ 'matches.played_at <= ?', time ],
      :joins => 'LEFT JOIN teams ON memberships.team_id = teams.id LEFT JOIN matches ON teams.match_id = matches.id',
      :order => 'matches.played_at DESC')
      
    membership.nil? ? 2000 : membership.current_ranking
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
  
  def set_feed_token
    self.update_attribute :feed_token, encrypt("#{email}--#{5.minutes.ago.to_s}")
  end
  
  def set_login_token
    self.update_attribute :login_token, encrypt("#{email}--#{5.minutes.ago.to_s}")
  end

  protected
    def remove_matches
      self.memberships.each do |membership|
        match = membership.team.match
        match.postpone_ranking_update = true
        match.destroy
      end
    
      # Fix stats
      Match.reset_rankings(self.account)
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