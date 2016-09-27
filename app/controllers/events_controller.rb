class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /events
  def index
    @events = Event.all
  end

  # GET /events/1
  def show
    @new_comment    = Comment.build_from(@event, current_user.id, "")

    @restaurant = @event.restaurant
    @map_hash = Gmaps4rails.build_markers(@restaurant) do |restaurant, marker|
      marker.lat restaurant.latitude
      marker.lng restaurant.longitude
    end

    if params[:join] == "true"
      GuestList.create(:event_id => @event.id, :user_id => current_user.id)

      flash[:notice] = 'You succesfully joined an event.'
      redirect_to event_path(@event), "method"=>"get"
    end

  end

  # GET /events/new
  def new
    @event = Event.new
    @restaurant = Restaurant.find_by :yelp_id => params[:restaurant]
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  def create
    @restaurant = Restaurant.find_by :yelp_id => params[:event][:restaurant]
    @event = Event.new(event_params)
    @event.user_id = current_user.id
    @event.user = current_user
    @event.restaurant_id = @restaurant.id
    @event.time = params[:event][:time]

    respond_to do |format|
      if @event.save
        format.html { redirect_to dashboard_url }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    params.require(:event).permit(:user_id, :restaurant_id, :message)
  end
end
