class Api::Admin::TablesController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_table, only: [:show, :update, :destroy]

  def index
    @tables = Table.includes(:time_slots)
    
    # Filter by area if provided
    @tables = @tables.by_area(params[:area]) if params[:area].present?
    # Filter by capacity if provided
    @tables = @tables.by_capacity(params[:capacity]) if params[:capacity].present?

    render json: {
      tables: @tables.map { |t| table_response(t) }
    }
  end

  def create
    @table = Table.new(table_params)
    
    if @table.save
      render json: {
        table: table_detailed_response(@table),
        message: 'Table created successfully'
      }, status: :created
    else
      render json: { errors: @table.errors }, status: :unprocessable_entity
    end
  end

  def show
    render json: { table: table_detailed_response(@table) }
  end

  def update
    if @table.update(table_params)
      render json: {
        table: table_detailed_response(@table),
        message: 'Table updated successfully'
      }
    else
      render json: { errors: @table.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if @table.time_slots.exists?
      render json: { error: 'Cannot delete table with existing time slots' }, status: :unprocessable_entity
    else
      @table.destroy
      render json: { message: 'Table deleted successfully' }
    end
  end

  private

  def set_table
    @table = Table.find(params[:id])
  end

  def table_params
    params.require(:table).permit(:name, :capacity, :area, :price_per_person, features: [])
  end

  def table_response(table)
    {
      id: table.id,
      name: table.name,
      capacity: table.capacity,
      area: table.area,
      features: table.features_list,
      price_per_person: table.price_per_person,
      total_time_slots: table.time_slots.count,
      available_time_slots: table.time_slots.available.count,
      created_at: table.created_at
    }
  end

  def table_detailed_response(table)
    table_response(table).merge(
      upcoming_reservations: table.reservations
                                 .joins(:time_slot)
                                 .where('time_slots.date >= ?', Date.current)
                                 .where(status: ['confirmed', 'pending'])
                                 .count
    )
  end
end
