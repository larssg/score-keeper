class UserOpenid < ActiveRecord::Base
  belongs_to :user
  before_save :normalize_openid_url!
  
  def denormalized_url
    self.openid_url.gsub(%r{^https?://}, '').gsub(%r{/$},'')
  end
  
  
  private
  def normalize_openid_url!
    @attributes['openid_url'] = OpenIdAuthentication.normalize_url(self.openid_url)
  end
  
end
