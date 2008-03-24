class LogsController < ApplicationController
  around_filter :login_from_feed_token, :only => [ :index ]
  before_filter :domain_required
  before_filter :login_required

  def index
    @logs = current_account.logs.find(:all, :order => 'published_at DESC', :limit => 20)
    
    respond_to do |format|
      format.atom
    end
  end
end