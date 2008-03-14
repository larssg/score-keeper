class Comment < ActiveRecord::Base
  belongs_to :match, :counter_cache => true
  belongs_to :user, :counter_cache => true
  
  validates_presence_of :body
end