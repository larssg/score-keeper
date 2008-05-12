class PagesController < ApplicationController
  session :off
  
  layout 'public'
  
  def login
    redirect_to account_url(params[:domain])
  end
end
