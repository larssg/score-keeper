require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  attr_accessor :identity_url
  
  has_many :user_openids, :dependent => :destroy

  validates_presence_of     :email,                       :if => :not_openid?
  validates_length_of       :email,    :within => 3..100, :if => :not_openid?
  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..100
  validates_uniqueness_of   :login,    :case_sensitive => false, :message => 'is already taken; sorry!'
  validates_uniqueness_of   :email,    :case_sensitive => false, :message => 'is already being used; do you already have an account?'

  validates_presence_of     :password,                    :if => :password_required?
  validates_presence_of     :password_confirmation,       :if => :password_required?
  validates_length_of       :password, :within => 4..40,  :if => :password_required?
  validates_confirmation_of :password,                    :if => :password_required?
  before_save :encrypt_password
  after_create :make_user_openid
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :name, :identity_url
  
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

  def self.find_by_identity_url(openid_url)
    user_openid = UserOpenid.find_by_openid_url(openid_url, :include => :user)
    user_openid.nil? ? nil : user_openid.user
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      not_openid? && (crypted_password.blank? || !password.blank?)
    end
  
    def not_openid?
      identity_url.blank? && user_openids.count == 0
    end
    
    def make_user_openid
      self.user_openids.create(:openid_url => identity_url) unless identity_url.blank?
    end  
end