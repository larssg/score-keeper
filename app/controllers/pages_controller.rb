# frozen_string_literal: true
class PagesController < ApplicationController
  layout 'public'

  def index
    @news = NewsItem.all(:order => 'posted_at DESC', :limit => 2)
  end

  def login
    redirect_to account_url(params[:domain])
  end
end
