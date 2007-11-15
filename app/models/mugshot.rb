class Mugshot < ActiveRecord::Base
  has_attachment :content_type => :image, 
                 :storage => :file_system, 
                 :max_size => 2.megabytes,
                 :thumbnails => { :thumb => '60x60>', :portrait => '220x300>' }

  validates_as_attachment
end