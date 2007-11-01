class ApplicationController < ActionController::Base
  before_filter :adjust_format_for_iphone
  around_filter :set_language

  include AuthenticatedSystem

  helper :all # include all helpers, all the time
  protect_from_forgery

  def language
    session[:language]
  end
  helper_method :language

  private
  def set_language
    session[:language] = params[:language] || session[:language]
    Gibberish.use_language(session[:language]) { yield }
  end
  
  def adjust_format_for_iphone
    if request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(iPhone|iPod)/]
      request.format = :iphone
    end
  end
end