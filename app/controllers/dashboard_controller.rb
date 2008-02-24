class DashboardController < ApplicationController
  before_filter :verify_domain
  before_filter :login_required

  def index
    @recent_games = current_account.games.find_recent(:limit => 10, :include => { :teams => :memberships })
    @comments = Comment.find(:all, :conditions => { :user_id => current_account.user_ids }, :limit => 5, :order => 'created_at DESC')

    unless cached?
      @rankings = current_account.users.find_ranked
      @newbies = current_account.users.find_newbies
      @games_per_day = current_account.games.count(:group => :played_on, :limit => 10, :order => 'games.played_on DESC')

      # Sidebar
      @leader = @rankings.size > 0 ? @rankings[0] : @newbies[0]
      @game_count = current_account.games.count
      @goals_scored = current_account.users.sum(:goals_for) / 2
      @all_time_high = Membership.all_time_high(current_account)
      @all_time_low = Membership.all_time_low(current_account)
    end
  end

  protected
  def cached?
    read_fragment(root_path) && read_fragment(root_path + '_sidebar')
  end
end