class Game < ActiveRecord::Base
  belongs_to :account, :counter_cache => true
  has_many :matches, :dependent => :destroy
  has_many :logs, :dependent => :delete_all
  has_many :game_participations, :dependent => :delete_all
  has_many :memberships, :dependent => :delete_all
  has_many :users, :through => :game_participations

  validates_presence_of :name, :team_size
  validates_inclusion_of :team_size, :in => (1..3)

  before_save :format_player_roles

  before_destroy :delete_teams_and_comments

  default_scope order('name')

  def ranked_game_participators
    @ranked_users ||= self.game_participations.find(:all,
                                                    :order => 'game_participations.ranking DESC, game_participations.matches_won DESC',
                                                    :conditions => ['users.enabled = ? AND game_participations.matches_played >= ?', true, self.newbie_limit],
                                                    :include => :user)
  end

  def newbie_game_participators
    @newbie_users ||= self.game_participations.find(:all,
                                                    :order => 'game_participations.matches_played DESC, game_participations.ranking DESC, game_participations.matches_won DESC',
                                                    :conditions => ['users.enabled = ? AND game_participations.matches_played < ?', true, self.newbie_limit],
                                                    :include => :user)
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
    game_participations.find_by(user_id: user.id)
  end

  def cache_key
    updated_at.to_s(:db).gsub(' ', '-')
  end

  def y_max
    max = [Membership.all_time_high(self).try(:current_ranking), 2000].compact.max
    (max / 100.0).ceil * 100 # Round up to nearest 100
  end

  def y_min
    min = [Membership.all_time_low(self).try(:current_ranking), 2000].compact.min
    (min / 100.0).floor * 100 # Round down to nearest 100
  end

  def matches_per_day(limit = 10)
    matches.group(:played_on).limit(limit).order('matches.played_on DESC').count
  end

  protected
  def delete_teams_and_comments
    matches.each do |match|
      Team.delete_all("match_id = #{match.id}")
      Comment.delete_all("match_id = #{match.id}")
    end
  end

  def format_player_roles
    return if !self.attributes.has_key?(:player_roles) || player_roles.blank?
    player_roles = self.player_roles.split("\n").collect { |pr| pr.strip }.select { |pr| pr.size > 0 }.join("\n")
  end
end
