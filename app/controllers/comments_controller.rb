class CommentsController < ApplicationController
  def create
    @game = Game.find(params[:game_id])
    if @game
      @comment = @game.comments.build(params[:comment])
      @comment.user = current_user
      if @comment.save
        redirect_to @game
      else
        flash[:notice] = 'Unable to save comment'[]
        redirect_to @games
      end
    end
  end  
end