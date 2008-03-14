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
        flash[:notice] = 'Comment added successfully.'[]
        redirect_to @match
      else
        flash[:notice] = 'Unable to save comment.'[]
        redirect_to @match
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
      flash[:notice] = 'Changes saved successfully.'[]
      redirect_to @comment.match
    end
  end
end