class CommentsController < ApplicationController
  before_action :domain_required
  before_action :login_required

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
        flash[:notice] = 'Comment added successfully.'
        redirect_to game_match_url(@match.game, @match)
      else
        flash[:error] = 'Unable to save comment.'
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
      flash[:notice] = 'Changes saved successfully.'
    elsif @comment.body?
      flash[:warning] = 'Please enter a comment.'
    else
      flash[:error] = 'An error occured while saving the comment. Please try again.'
    end
    redirect_to game_match_url(@comment.match.game, @comment.match)
  end
end
