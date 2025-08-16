class Api::TimeSlotsController < ApplicationController
  def index
    @time_slots = TimeSlot.includes(:table)
                         .available
                         .upcoming
    
    # Apply filters
    @time_slots = @time_slots.on_date(params[:date]) if params[:date].present?
    @time_slots = @time_slots.for_capacity(params[:party_size]) if params[:party_size].present?
    @time_slots = @time_slots.in_area(params[:area]) if params[:area].present?
    
    # Pagination
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    @time_slots = @time_slots.page(page).per(per_page) rescue @time_slots.limit(per_page.to_i)
    
    render json: {
      time_slots: @time_slots.map { |ts| time_slot_response(ts) },
      meta: {
        total: @time_slots.respond_to?(:total_count) ? @time_slots.total_count : @time_slots.count,
        page: page.to_i,
        per_page: per_page.to_i
      }
    }
  end

  def show
    @time_slot = TimeSlot.includes(:table).find(params[:id])
    render json: { time_slot: time_slot_detailed_response(@time_slot) }
  end

  private

  def time_slot_response(time_slot)
    {
      id: time_slot.id,
      date: time_slot.date,
      start_time: time_slot.start_time,
      end_time: time_slot.end_time,
      time_range: time_slot.time_range,
      is_available: time_slot.is_available,
      available_for_reservation: time_slot.available_for_reservation?,
      table: {
        id: time_slot.table.id,
        name: time_slot.table.name,
        capacity: time_slot.table.capacity,
        area: time_slot.table.area,
        features: time_slot.table.features_list,
        price_per_person: time_slot.table.price_per_person
      }
    }
  end

  def time_slot_detailed_response(time_slot)
    time_slot_response(time_slot).merge(
      notes: time_slot.notes,
      duration_minutes: time_slot.duration_minutes,
      created_at: time_slot.created_at
    )
  end
end
