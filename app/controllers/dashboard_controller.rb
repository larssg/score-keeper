class DashboardController < ApplicationController
  before_filter :domain_required
  before_filter :login_required

  def index
    @logs = current_game.logs.find(:all, :order => 'published_at DESC', :limit => 5)
    respond_to do |format|
      format.js do
        if @logs.size > 0 && @logs.first.published_at.to_s(:db) != params[:last_update]
          load_data
          render :action => 'index', :layout => false
        else
          head 200
        end
      end
      format.html { load_data }
    end
  end
  
  protected
  def load_data
    @recent_matches = current_game.matches.find_recent(nil, :limit => 10, :include => { :teams => :memberships })

    @rankings = current_game.ranked_game_participators
    @newbies = current_game.newbie_game_participators
    @matches_per_day = current_game.matches.count(:group => :played_on, :limit => 10, :order => 'matches.played_on DESC')

    # Sidebar
    @leader = @rankings.size > 0 ? @rankings[0] : @newbies[0]
    @match_count = current_game.matches.count
    
    total_points_for = current_game.game_participations.sum(:points_for)
    @points = total_points_for.nil? ? 0 : total_points_for / current_game.team_size

    @all_time_high = Membership.all_time_high(current_game)
    @all_time_low = Membership.all_time_low(current_game)

    # Get positions 7 days ago
    @positions = {}
    last_month = current_game.matches.find(:first, :order => 'played_at ASC', :conditions => ['played_at >= ?', 7.days.ago])
    unless last_month.blank? || last_month.positions.blank?
      last_month.positions.each_with_index do |user_id, index|
        @positions[user_id] = {}
        @positions[user_id][:now] = find_user(user_id).position(current_game)
        @positions[user_id][:then] = index + 1
      end
    end
  end
end