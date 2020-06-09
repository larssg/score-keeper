class Comment < ActiveRecord::Base
  belongs_to :match, :counter_cache => true
  belongs_to :user, :counter_cache => true

  validates_presence_of :body

  after_save :log

  default_scope order('created_at')

  protected
  def log
    return if match.blank? || match.account.blank?

    Log.clear_item_log(match.account, self)

    match.account.logs.create(:linked_model => self.class.name,
                                   :linked_id => id,
                                   :user => user,
                                   :game => match.game,
                                   :message => "#{user.name} said: #{body}",
                                   :published_at => created_at)

    match.game.touch
  end
end
