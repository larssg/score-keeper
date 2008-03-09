class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include AccountLocation

#  around_filter :set_language

  include AuthenticatedSystem

  helper :all # include all helpers, all the time
#  protect_from_forgery :secret => 'f22c29e38d18cebc96d57d166b462fe45c52f25c14487e8fe75fd2989f5795997db0bb1178a453bfc9f83b12a54bc61210a06d7bbc82393bc317961a2b635675'

  protected
  def language
    session[:language]
  end
  helper_method :language
  
  def all_users
    current_account.all_users
  end
  helper_method :all_users
  
  def find_user(id)
    @indexed_users ||= all_users.group_by(&:id)
    @indexed_users[id.to_i].first
  end
  helper_method :find_user

  def cache_key(extra = nil)
    key = [self.controller_name]
    key << account_subdomain unless account_subdomain.nil?
    key << extra unless extra.nil?
    key.join('_')
  end
  helper_method :cache_key
  
  def domain_required
    return true if disable_subdomains?
    redirect_to public_root_url and return false if account_subdomain.blank?
    redirect_to account_url(current_user.account.domain) and return false if logged_in? && current_user.account.domain != account_subdomain
    redirect_to public_root_url(:host => account_domain) and return false if !logged_in? && Account.find_by_domain(account_subdomain).nil?
    true
  end
  
  def current_account
    if @current_account.nil?
      unless account_subdomain.nil?
        @current_account ||= Account.find_by_domain(account_subdomain)
        redirect_to account_url(current_account.account.domain) if logged_in? && current_user.account.domain != @current_account.domain
      end
    end
    return @current_account
  end
  helper_method :current_account
  
  def time_periods
    [
      ['30 days'[], 30],
      ['90 days'[], 90],
      ['180 days'[], 180],
      ['360 days'[], 360]
    ]
  end
  helper_method :time_periods
  
  def setup_ranking_graph
    chart = FlashChart.new
    chart.title ' '
    chart.set_y_max y_max
    chart.set_y_min y_min
    chart.y_label_steps y_axis_steps(y_min, y_max)
    chart.set_y_legend('Ranking'[], 12, '#000000')
    
    chart
  end
  
  def y_max
    max = [Membership.all_time_high(current_account).current_ranking, 2000].max
    (max / 100.0).ceil * 100 # Round up to nearest 100
  end
  
  def y_min
    min = [Membership.all_time_low(current_account).current_ranking, 2000].min
    (min / 100.0).floor * 100 # Round down to nearest 100
  end
  
  def y_axis_steps(min, max)
    (max - min) / 100
  end

  def disable_subdomains?
    RAILS_ENV == 'test'
  end
  
  def must_be_account_admin
    redirect_to root_url unless current_user.is_account_admin? || current_user.is_admin?
  end
  
  def must_be_admin
    redirect_to root_url unless current_user.is_admin?
  end
  
  private
  def set_language
    session[:language] = params[:language] || session[:language]
    Gibberish.use_language(session[:language]) { yield }
  end
end