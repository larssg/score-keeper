class Game < ActiveRecord::Base
  belongs_to :account
  has_many :matches
  has_many :logs
  has_many :game_participations
  has_many :memberships
  has_many :users, :through => :game_participations
  
  validates_presence_of :name, :team_size
  
  before_save :format_player_roles
  
  def ranked_game_participators
    @ranked_users ||= self.game_participations.find(:all, :order => 'game_participations.ranking DESC, game_participations.matches_won DESC', :conditions => ['users.enabled = ? AND game_participations.matches_played >= ?', true, self.newbie_limit], :include => :user)
  end
  
  def newbie_game_participators
    @newbie_users ||= self.game_participations.find(:all, :order => 'game_participations.matches_played DESC, game_participations.ranking DESC, game_participations.matches_won DESC', :conditions => ['users.enabled = ? AND game_participations.matches_played < ?', true, self.newbie_limit], :include => :user)
  end  
  
  def user_positions
    @user_positions ||= self.ranked_game_participators + self.newbie_game_participators
  end
  
  def role(position)
    return roles[position].strip if roles.size > position
    ''
  end
  
  def roles
    if @roles.nil?
      if player_roles.blank?
        @roles = ['']
      else
        @roles = player_roles.split("\n").collect { |pr| pr.strip }
      end
    end
    @roles
  end
  
  def roles=(new_roles)
    @roles = nil
    player_roles = new_roles.join("\n")
    format_player_roles
  end
  
  def game_participation_for(user)
    game_participations.find_by_user_id(user.id)
  end
  
  protected
  def format_player_roles
    return if !self.attributes.has_key?(:player_roles) || player_roles.blank?
    player_roles = self.player_roles.split("\n").collect { |pr| pr.strip }.select { |pr| pr.size > 0 }.join("\n")
  end
end
