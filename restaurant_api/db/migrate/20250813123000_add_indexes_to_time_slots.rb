class AddIndexesToTimeSlots < ActiveRecord::Migration[8.0]
  def change
    unless index_exists?(:time_slots, :date)
      add_index :time_slots, :date
    end
    unless index_exists?(:time_slots, :table_id)
      add_index :time_slots, :table_id
    end
  end
end
