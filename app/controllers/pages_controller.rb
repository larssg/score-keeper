class PagesController < ApplicationController
  layout 'public'

  def index
    @news = NewsItem.find(:all, :order => 'posted_at DESC', :limit => 2)
  end

  def login
    redirect_to account_url(params[:domain])
  end
end
