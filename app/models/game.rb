class Game < ActiveRecord::Base
  belongs_to :account
  has_many :matches
  has_many :game_participations
  has_many :users, :through => :game_participations
  
  validates_presence_of :name, :team_size, :newbie_limit
  
  def ranked_game_participators
    @ranked_users ||= self.game_participations.find(:all, :order => 'game_participations.ranking DESC, game_participations.matches_won DESC', :conditions => ['users.enabled = ? AND game_participations.matches_played >= ?', true, self.newbie_limit], :include => :user)
  end
  
  def newbie_game_participators
    @newbie_users ||= self.game_participations.find(:all, :order => 'game_participations.matches_played DESC, game_participations.ranking DESC, game_participations.matches_won DESC', :conditions => ['users.enabled = ? AND game_participations.matches_played < ?', true, self.newbie_limit], :include => :user)
  end  
  
  def user_positions
    @user_positions ||= self.ranked_users + self.newbie_users
  end
end
