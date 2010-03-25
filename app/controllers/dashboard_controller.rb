class DashboardController < ApplicationController
  before_filter :domain_required
  before_filter :login_required

  def index
    return if game.nil?

    if params[:last_update]
      if logs.size > 0 && last_update != params[:last_update]
        render :action => 'index', :layout => false
      else
        head 200
      end
    end
  end
  
  helper_method :game
  helper_method :logs
  helper_method :last_update
  helper_method :recent_matches
  helper_method :rankings
  helper_method :newbies
  helper_method :matches_per_day
  helper_method :leader
  helper_method :match_count
  helper_method :points
  helper_method :all_time_high
  helper_method :all_time_low
  helper_method :positions
  helper_method :news

  protected
  def game
    return @game unless @game.nil?
    if params[:game_id] && params[:game_id].to_i != current_game.id
      @game = current_account.games.find(params[:game_id])
    end
    @game ||= current_game
  end

  def logs
    return nil if game.nil?
    @logs ||= game.logs.find(:all, :order => 'published_at DESC', :limit => 5)
  end 
  
  def last_update
    return nil if logs.nil? || logs.first.nil?
    logs.first.published_at.to_s(:db)
  end
   
  def recent_matches
    @recent_matches ||= @game.matches.find_recent(nil,
                                                  :limit => 10,
                                                  :include => { :teams => :memberships })
  end

  def rankings
    @rankings ||= @game.ranked_game_participators
  end

  def newbies
    @newbies ||= @game.newbie_game_participators
  end

  def matches_per_day
    @matches_per_day ||= @game.matches.count(:group => :played_on,
                                           :limit => 10,
                                           :order => 'matches.played_on DESC')
  end

  def leader
    @leader ||= rankings.size > 0 ? rankings[0] : newbies[0]
  end

  def match_count
    @match_count ||= @game.matches.size
  end

  def points
    return @points unless @points.nil?
    total_points_for = @game.game_participations.sum(:points_for)
    @points ||= total_points_for.nil? ? 0 : total_points_for / @game.team_size
  end

  def all_time_high
    @all_time_high ||= Membership.all_time_high(current_game)
  end

  def all_time_low
    @all_time_low ||= Membership.all_time_low(current_game)
  end

  def positions
    return @positions unless @positions.nil?
    
    # Get positions 7 days ago
    @positions = {}
    last_month = @game.matches.find(:first,
                                    :order => 'played_at ASC',
                                    :conditions => ['played_at >= ?', 7.days.ago])
    unless last_month.blank? || last_month.positions.blank?
      last_month.positions.each_with_index do |user_id, index|
        @positions[user_id] = {}
        @positions[user_id][:now] = find_user(user_id).position(current_game)
        @positions[user_id][:then] = index + 1
      end
    end

    @positions
  end

  def news
    @news ||= NewsItem.find(:all, :order => 'posted_at DESC', :limit => 3)
  end
end
