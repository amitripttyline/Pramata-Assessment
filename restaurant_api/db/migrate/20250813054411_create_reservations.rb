class CreateReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :time_slot, null: false, foreign_key: true
      t.integer :party_size, null: false
      t.text :special_requests
      t.string :status, null: false, default: 'pending'
      t.datetime :reservation_date, null: false

      t.timestamps
    end
    
    add_index :reservations, [:user_id, :reservation_date]
    add_index :reservations, [:time_slot_id, :status]
  end
end
