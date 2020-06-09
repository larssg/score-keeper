class Comment < ActiveRecord::Base
  belongs_to :match, :counter_cache => true
  belongs_to :user, :counter_cache => true

  validates :body, presence: true

  after_save :log

  default_scope order('created_at')

  protected
  def log
    return if self.match.blank? || self.match.account.blank?

    Log.clear_item_log(self.match.account, self)

    self.match.account.logs.create(:linked_model => self.class.name,
                                   :linked_id => self.id,
                                   :user => self.user,
                                   :game => self.match.game,
                                   :message => "#{self.user.name} said: #{self.body}",
                                   :published_at => self.created_at)

    self.match.game.touch
  end
end
