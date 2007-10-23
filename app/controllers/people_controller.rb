class PeopleController < ApplicationController
  before_filter :login_required, :except => :index
  
  make_resourceful do
    publish :json, :csv, :attributes => [ :first_name, :last_name, :display_name, :ranking, :memberships_count, :games_won ]
    build :all
    
    before :index do
      @person = current_model.new
    end
    
    before :create, :update do
      mugshot = Mugshot.create(params[:mugshot])
      current_object.mugshot = mugshot unless mugshot.nil?
    end
    
    response_for :create, :update do
      redirect_to people_url
    end
  end

  def current_objects
    @current_objects ||= current_model.find_all
  end
end