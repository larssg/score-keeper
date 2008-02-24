class CommentsController < ApplicationController
  before_filter :domain_required
  before_filter :login_required

  def show
    @comment = current_user.comments.find(params[:id])
    render :layout => false
  end

  def create
    @game = Game.find(params[:game_id])
    if @game
      @comment = @game.comments.build(params[:comment])
      @comment.user = current_user
      if @comment.save
        flash[:notice] = 'Comment added successfully.'[]
        redirect_to @game
      else
        flash[:notice] = 'Unable to save comment.'[]
        redirect_to @game
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
      redirect_to @comment.game
    end
  end
end