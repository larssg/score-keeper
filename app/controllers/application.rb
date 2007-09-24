class ApplicationController < ActionController::Base
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
end