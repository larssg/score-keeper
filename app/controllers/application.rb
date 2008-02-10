class ApplicationController < ActionController::Base
  around_filter :set_language

  include AuthenticatedSystem

  helper :all # include all helpers, all the time
#  protect_from_forgery :secret => 'f22c29e38d18cebc96d57d166b462fe45c52f25c14487e8fe75fd2989f5795997db0bb1178a453bfc9f83b12a54bc61210a06d7bbc82393bc317961a2b635675'

  def language
    session[:language]
  end
  helper_method :language

  protected
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
    max = [Membership.all_time_high.current_ranking, 2000].max
    (max / 100.0).ceil * 100 # Round up to nearest 100
  end
  
  def y_min
    min = [Membership.all_time_low.current_ranking, 2000].min
    (min / 100.0).floor * 100 # Round down to nearest 100
  end
  
  def y_axis_steps(min, max)
    (max - min) / 100
  end
  
  private
  def set_language
    session[:language] = params[:language] || session[:language]
    Gibberish.use_language(session[:language]) { yield }
  end
end