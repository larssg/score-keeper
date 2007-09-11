class Membership < ActiveRecord::Base
  belongs_to :team
  belongs_to :person, :counter_cache => true
end