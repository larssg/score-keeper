class UsersController < ApplicationController
  before_filter :domain_required
  before_filter :login_required, except: [:forgot_password]
  before_filter :must_be_account_admin_or_self, only: [:edit, :update]

  def index
    @users = all_users
    @user = current_account.users.build
  end

  def show
    @game = current_account.games.find(params[:game_id])
    @user = current_account.users.find(params[:id])

    @game_participation = @user.game_participations.find_by_game_id(@game.id)

    redirect_to root_url and return if @game_participation.nil?

    @time_period = params[:period] ? params[:period].to_i : 30
    @all_time_high = @user.all_time_high(@game)
    @all_time_low = @user.all_time_low(@game)
    @matches_per_day =
      @game_participation.memberships.count(
        group: 'matches.played_on',
        limit: 10,
        order: 'matches.played_on DESC',
        joins: 'LEFT JOIN teams ON memberships.team_id = teams.id LEFT JOIN matches ON teams.match_id = matches.id'
      )

    if @game.team_size > 1
      @team_counts =
        @user.teams.count(group: :team_ids, conditions: ['memberships.game_id = ?', @game.id]).sort_by do |t|
          t[1]
        end.reverse
      @team_wins =
        @user.teams.joins(:memberships).where(won: true, memberships: { game_id: @game.id }).group('team_ids').count
      @teams =
        current_account.teams.find(
          :all,
          group: :team_ids, conditions: { team_ids: @team_counts.collect { |tc| tc[0] } }
        )

      @teams =
        @teams.collect do |team|
          {
            team: team,
            played: @team_counts.select { |tc| tc[0] == team.team_ids }[0],
            wins: @team_wins[team.team_ids].to_i / 2
          }
        end

      if @game.team_size == 2
        @teams.each do |team|
          team_mate = team[:team].team_mate_for(@user)
          team[:team_mate] = team_mate
          team[:team_mate_game_participation] = @game.game_participation_for(team_mate)
          team[:played] = team[:played].blank? ? 0 : team[:played][1].blank? ? 0 : team[:played][1].to_i
          team[:wins] = team[:wins].blank? ? 0 : team[:wins]
          team[:win_percentage] = format('%01.1f', (team[:wins].to_f * 100.0 / team[:played].to_f))
        end
      end

      @teams = @teams.sort_by { |t| t[:win_percentage].to_f }.reverse
    end

    @json = chart_json(@time_period, @game_participation)
  rescue ActiveRecord::RecordNotFound
    flash[:warning] = "No user was found with that ID (#{params[:id]})."
    redirect_to root_url
  end

  def new
    @user = User.new(params[:user])
    @user.account = current_account
    @user.time_zone ||= current_account.time_zone
    @user.valid? if params[:user]
  end

  def create
    @user = User.new(params[:user])
    @user.account = current_account

    if current_user.is_admin? && params[:user][:is_admin]
      @user.is_admin = true
    end

    @user.save!

    flash[:notice] = 'User created successfully'
    redirect_to users_path
  rescue ActiveRecord::RecordInvalid
    render action: 'new'
  end

  def edit
    @user = current_account.users.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:warning] = "No user was found with that ID (#{params[:id]})."
    redirect_to root_url
  end

  def update
    @user = current_account.users.find(params[:id])
    @user.is_account_admin = params[:user][:is_account_admin] if (
      current_user.is_account_admin? || current_user.is_admin?
    ) && !params[:user][:is_account_admin].nil?
    if current_user.is_admin? && params[:user][:is_admin]
      @user.is_admin = params[:user][:is_admin]
    end
    @user.enabled = params[:user][:enabled] if (current_user.is_account_admin? || current_user.is_admin?) &&
                                               !params[:user][:enabled].nil?

    if @user.update_attributes(params[:user])
      redirect_to users_url
      flash[:notice] = 'User saved successfully.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @user = current_account.users.find(params[:id])

    if @user.destroy
      if @user.id == current_user
        self.current_user.forget_me if logged_in?
        cookies.delete :auth_token
        reset_session
        flash[:notice] = 'You have removed your account.'
        redirect_back_or_default('/')
      else
        flash[:notice] = 'User deleted.'
        redirect_to users_path
      end
    else
      flash[:error] = 'Unable to destroy account'
      render action: 'edit'
    end
  end

  def forgot_password
    if params[:username] || params[:email]
      user = current_account.users.find_by_login(params[:username]) if params[:username]
      user ||= current_account.users.find_by_email(params[:email]) if params[:email]

      unless user.blank?
        flash[:notice] = 'You should receive an email containing a one-time login link shortly.'
        user.set_login_token
        UserMailer.forgot_password_info(user).deliver
        redirect_to login_url
        return
      else
        flash.now[:error] = 'No user was found with the specified username or e-mail.'
      end
    end
    render layout: 'login'
  end

  protected

  def chart_json(time_period, game_participation)
    from = time_period.days.ago

    memberships =
      game_participation.memberships.find(
        :all,
        conditions: ['matches.played_at >= ?', from],
        order: 'memberships.id',
        select: 'memberships.current_ranking, memberships.created_at, matches.played_at AS played_at',
        joins: 'LEFT JOIN teams ON memberships.team_id = teams.id LEFT JOIN matches ON teams.match_id = matches.id'
      )

    values = [game_participation.ranking_at(from)] + memberships.collect(&:current_ranking)
    x_labels = ['Start'] + memberships.collect { |m| m.played_at.to_time.to_s :db }

    steps = (memberships.size / 20).to_i

    {
      elements: [
        {
          type: 'line',
          colour: '#3399CC',
          'dot-style' => { 'dot-size' => 4, tip: '#val#<br>#x_label#', type: 'dot' },
          values: values
        }
      ],
      y_legend: { text: 'Ranking', style: '{color: #000000; font-size: 12px}' },
      y_axis: {
        min: current_game.y_min, max: current_game.y_max, steps: 100, colour: '#808080', 'grid-colour' => '#dddddd'
      },
      x_axis: {
        steps: steps,
        labels: { labels: x_labels, 'steps' => steps, rotate: 315 },
        colour: '#808080',
        'grid-colour' => '#dddddd'
      },
      bg_colour: '#ffffff',
      tooltip: {
        shadow: false,
        body: '{font-size: 10px; font-weight: normal; color: #000000;}',
        title: '{font-size: 14px; color: #000;}',
        background: '#ffffff',
        colour: '#3399cc',
        stroke: 3
      }
    }.to_json
  end

  def must_be_account_admin_or_self
    redirect_to root_url unless current_user.id.to_s == params[:id] || current_user.is_account_admin? ||
                                current_user.is_admin?
  end

  def must_be_admin_or_self
    unless current_user.id.to_s == params[:id] || current_user.is_admin?
      redirect_to root_url
    end
  end
end
