class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :reservation, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :comment

      t.timestamps
    end
    
    add_index :reviews, [:user_id, :reservation_id], unique: true
    add_index :reviews, :rating
    add_index :reviews, :created_at
  end
end
