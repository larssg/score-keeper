class Log < ActiveRecord::Base
  belongs_to :account
  belongs_to :user
  
  before_save :set_published_at
  
  def set_published_at
    self.published_at = Time.now if self.published_at.blank?
  end
end
