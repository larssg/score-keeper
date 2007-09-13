class TeamsController < ApplicationController
  def index
    @teams = Team.count(:group => :team_ids).sort_by { |t| t[1] }.reverse
  end
end