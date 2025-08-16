class CreateTables < ActiveRecord::Migration[8.0]
  def change
    create_table :tables do |t|
      t.string :name, null: false
      t.integer :capacity, null: false
      t.string :area, null: false
      t.text :features
      t.decimal :price_per_person, precision: 8, scale: 2

      t.timestamps
    end
    
    add_index :tables, :name, unique: true
    add_index :tables, :capacity
    add_index :tables, :area
  end
end
