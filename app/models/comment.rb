class Comment < ActiveRecord::Base
  belongs_to :match, :counter_cache => true
  belongs_to :user, :counter_cache => true
  
  validates_presence_of :body
  
  after_create :log
  
  protected
  def log
    return if self.match.blank? || self.match.account.blank?
    self.match.account.logs.create(:linked_model => self.class.class_name,
      :linked_id => self.id,
      :user => self.user,
      :message => "#{self.user.name} said: #{self.body}",
      :published_at => self.created_at)
  end
end