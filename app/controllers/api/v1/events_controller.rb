class Api::V1::EventsController < ApplicationController

  before_action :find_event, only: [:show, :destroy]

  # GET /events
  def index
    @events = Event.all
    render json: @events.map{|event| event.serialize_report}
  end

  # GET /events/:id
  def show
    render json: @event.serialize_report
  end

  # POST /events
  def create
    @event = Event.new({raw: request.body.read})
    if @event.save
      render json: @event.serialize_report
    else
      render error: {error: "Unable to parse event"}, status: 400
    end
  end

  # PUT -- no implementation; assuming we do not want to modify a event submission

  # DELETE /events/:id
  def destroy
    if @event
      Comment.where(event_id: @event.id)&.destroy_all
      @event&.delete
      render json: {message: "Event #{@event.id} successfully deleted"}, status: 200
    else
      render json: {error: "Unable to delete event #{@event.id}"}, status: 400
    end
  end

  # GET /events/delete_all
  def destroy_all
    count = Event.all.count
    Comment.all.destroy_all
    Event.all.destroy_all
    render json: {message: "#{count} events deleted"}, status: 200
  end


  private

  def find_event
    @event = Event.find(params[:id])
  end

end
