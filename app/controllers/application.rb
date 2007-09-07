class ApplicationController < ActionController::Base
  around_filter :set_language

  include AuthenticatedSystem
  before_filter :login_from_cookie

  helper :all # include all helpers, all the time

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