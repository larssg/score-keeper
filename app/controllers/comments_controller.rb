class CommentsController < ApplicationController
  before_filter :domain_required
  before_filter :login_required

  def show
    @comment = current_user.comments.find(params[:id])
    render :layout => false
  end

  def create
    @match = current_account.matches.find(params[:match_id])
    if @match
      @comment = @match.comments.build(params[:comment])
      @comment.user = current_user
      if @comment.save
        flash[:notice] = t('comments.added')
        redirect_to game_match_url(@match.game, @match)
      else
        flash[:error] = t('comments.add_error')
        redirect_to game_match_url(@match.game, @match)
      end
    end
  end

  def edit
    @comment = current_user.comments.find(params[:id])
    respond_to do |format|
      format.html # edit.html.haml
      format.js # edit.js.haml
    end
  end

  def update
    @comment = current_user.comments.find(params[:id])
    if @comment.update_attributes(params[:comment])
      flash[:notice] = t('comments.updated')
    elsif @comment.body.blank?
      flash[:warning] = t('comments.update_error')
    else
      flash[:error] = t('comments.update_error')
    end
    redirect_to game_match_url(@comment.match.game, @comment.match)
  end
end
