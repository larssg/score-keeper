class PeopleController < ApplicationController
  make_resourceful do
    build :all
    
    before :index do
      @person = current_model.new
    end
    
    response_for :create, :update do
      redirect_to people_url
    end
  end

  def current_objects
    @current_objects ||= current_model.find_all
  end
end