class Log < ActiveRecord::Base
  belongs_to :account
  belongs_to :game
  belongs_to :user

  before_save :set_published_at

  def set_published_at
    self.published_at = Time.now if self.published_at.blank?
  end

  def self.find_by_item(account, item, model_name = nil)
    model_name = item.class.class_name if model_name.nil?
    account.logs.find(:all, :conditions => { :linked_model => model_name, :linked_id => item.id })
  end

  def self.clear_item_log(account, item)
    find_by_item(account, item).each { |item| item.destroy }
    if (item.class.class_name == "Match")
      find_by_item(account, item, 'Clean sheet').each { |item| item.destroy }
    end
  end
end
  