class MoveIdentityUrlToUserOpenidTable < ActiveRecord::Migration
  def self.up
    User.find(:all).each do |user|
      next if user.identity_url.blank?
      user.user_openids.create(:openid_url => user.identity_url)
    end
    remove_column :users, :identity_url
  end

  def self.down
    add_column :users, :identity_url, :string
    User.find(:all, :include => :user_openids).each do |user|
      user.identity_url = user.user_openids.first.openid_url unless user.user_openids.blank?
    end
  end
end
