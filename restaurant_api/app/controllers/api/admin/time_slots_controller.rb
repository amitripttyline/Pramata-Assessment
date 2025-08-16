class Api::Admin::TimeSlotsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_time_slot, only: [:update, :destroy]

  def create
    @table = Table.find(params[:table_id])
    @time_slot = @table.time_slots.build(time_slot_params)
    
    if @time_slot.save
      render json: {
        time_slot: time_slot_response(@time_slot),
        message: 'Time slot created successfully'
      }, status: :created
    else
      render json: { errors: @time_slot.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @time_slot.update(time_slot_params)
      render json: {
        time_slot: time_slot_response(@time_slot),
        message: 'Time slot updated successfully'
      }
    else
      render json: { errors: @time_slot.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if @time_slot.reservations.where(status: ['confirmed', 'pending']).exists?
      render json: { error: 'Cannot delete time slot with active reservations' }, status: :unprocessable_entity
    else
      @time_slot.destroy
      render json: { message: 'Time slot deleted successfully' }
    end
  end

  private

  def set_time_slot
    @time_slot = TimeSlot.find(params[:id])
  end

  def time_slot_params
    params.require(:time_slot).permit(:start_time, :end_time, :date, :is_available, :notes)
  end

  def time_slot_response(time_slot)
    {
      id: time_slot.id,
      date: time_slot.date,
      start_time: time_slot.start_time,
      end_time: time_slot.end_time,
      time_range: time_slot.time_range,
      is_available: time_slot.is_available,
      available_for_reservation: time_slot.available_for_reservation?,
      notes: time_slot.notes,
      duration_minutes: time_slot.duration_minutes,
      table: {
        id: time_slot.table.id,
        name: time_slot.table.name,
        capacity: time_slot.table.capacity,
        area: time_slot.table.area
      },
      reservations_count: time_slot.reservations.count,
      active_reservations_count: time_slot.reservations.where(status: ['confirmed', 'pending']).count
    }
  end
end
