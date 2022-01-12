class Api::V1::CommentsController < ApplicationController
  before_action :find_comment, only: [:show, :update, :destroy]
  before_action :event_id, only: [:index, :create, :destroy_all]

  # GET /comments
  def index
    render json: event_all_comments
  end

  # GET /comments/:id
  def show
    render json: @comment
  end

  # POST /comments/:id
  def create
    @comment = Comment.new({comment: request.body.read, event_id: @event_id})
    if @comment.save
      render json: @comment
    else
      render error: {error: "Unable to create comment."}, status: 400
    end
  end

  # PUT /comments/:id
  def update
    if @comment&.update({comment: request.body.read})
      render json: {message: "Comment successfully updated."}, status: 200
    else
      render json: {error: "Unable to delete comment."}, status: 400
    end
  end

  # DELETE /comments/:id
  def destroy
    if @comment&.destroy
      render json: {message: "Comment successfully deleted."}, status: 200
    else
      render json: {error: "Unable to delete comment."}, status: 400
    end
  end

  # GET /comments/delete_all
  def destroy_all
    count = event_all_comments.count
    event_all_comments.destroy_all
    render json: {message: "#{count} comments deleted"}, status: 200
  end

  private

  def event_all_comments
    Comment.where(event_id: @event_id)
  end

  def find_comment
    @comment = Comment.find(params[:id])
  end

  def event_id
    @event_id = Event.find(params[:event_id])&.id
  end

end
