class CreateTimeSlots < ActiveRecord::Migration[8.0]
  def change
    create_table :time_slots do |t|
      t.references :table, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.date :date, null: false
      t.boolean :is_available, default: true, null: false
      t.text :notes

      t.timestamps
    end
    
    add_index :time_slots, [:table_id, :date, :start_time]
    add_index :time_slots, [:date, :is_available]
  end
end
