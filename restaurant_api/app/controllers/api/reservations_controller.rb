class Api::ReservationsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_reservation, only: [:show, :update, :destroy]

  def index
    binding.pry
    @reservations = current_user.reservations.includes(:time_slot, :table)
                              .order(reservation_date: :desc)
    
    # Apply status filter
    @reservations = @reservations.where(status: params[:status]) if params[:status].present?
    
    render json: {
      reservations: @reservations.map { |r| reservation_response(r) }
    }
  end

  def show
    render json: { reservation: reservation_detailed_response(@reservation) }
  end

  def create
  @time_slot = TimeSlot.find(params[:reservation][:time_slot_id])
    
    unless @time_slot.available_for_reservation?
      return render json: { error: 'Time slot is not available' }, status: :unprocessable_entity
    end

    @reservation = current_user.reservations.build(reservation_params)
    @reservation.time_slot = @time_slot
    @reservation.reservation_date = DateTime.new(
      @time_slot.date.year,
      @time_slot.date.month, 
      @time_slot.date.day,
      @time_slot.start_time.hour,
      @time_slot.start_time.min
    )
    
    if @reservation.save
      render json: {
        reservation: reservation_detailed_response(@reservation),
        message: 'Reservation created successfully'
      }, status: :created
    else
      render json: { errors: @reservation.errors }, status: :unprocessable_entity
    end
  end

  def update
    unless @reservation.can_be_modified?
      return render json: { error: 'Reservation cannot be modified' }, status: :unprocessable_entity
    end

    if @reservation.update(reservation_update_params)
      render json: {
        reservation: reservation_detailed_response(@reservation),
        message: 'Reservation updated successfully'
      }
    else
      render json: { errors: @reservation.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    unless @reservation.can_be_cancelled?
      return render json: { error: 'Reservation cannot be cancelled' }, status: :unprocessable_entity
    end

    @reservation.update(status: 'cancelled')
    render json: { message: 'Reservation cancelled successfully' }
  end

  private

  def set_reservation
    @reservation = current_user.reservations.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:party_size, :special_requests)
  end

  def reservation_update_params
    params.require(:reservation).permit(:party_size, :special_requests, :status)
  end

  def reservation_response(reservation)
    {
      id: reservation.id,
      party_size: reservation.party_size,
      status: reservation.status,
      reservation_date: reservation.reservation_date,
      total_amount: reservation.total_amount,
      time_slot: {
        id: reservation.time_slot.id,
        date: reservation.time_slot.date,
        time_range: reservation.time_slot.time_range
      },
      table: {
        id: reservation.table.id,
        name: reservation.table.name,
        area: reservation.table.area,
        capacity: reservation.table.capacity
      },
      created_at: reservation.created_at
    }
  end

  def reservation_detailed_response(reservation)
    reservation_response(reservation).merge(
      special_requests: reservation.special_requests,
      can_be_modified: reservation.can_be_modified?,
      can_be_cancelled: reservation.can_be_cancelled?,
      time_slot: {
        id: reservation.time_slot.id,
        date: reservation.time_slot.date,
        start_time: reservation.time_slot.start_time,
        end_time: reservation.time_slot.end_time,
        time_range: reservation.time_slot.time_range,
        notes: reservation.time_slot.notes
      },
      table: {
        id: reservation.table.id,
        name: reservation.table.name,
        area: reservation.table.area,
        capacity: reservation.table.capacity,
        features: reservation.table.features_list,
        price_per_person: reservation.table.price_per_person
      }
    )
  end
end
