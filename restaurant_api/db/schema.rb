# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_13_123000) do
  create_table "reservations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "time_slot_id", null: false
    t.integer "party_size", null: false
    t.text "special_requests"
    t.string "status", default: "pending", null: false
    t.datetime "reservation_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["time_slot_id", "status"], name: "index_reservations_on_time_slot_id_and_status"
    t.index ["time_slot_id"], name: "index_reservations_on_time_slot_id"
    t.index ["user_id", "reservation_date"], name: "index_reservations_on_user_id_and_reservation_date"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "reviews", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "reservation_id", null: false
    t.integer "rating", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_reviews_on_created_at"
    t.index ["rating"], name: "index_reviews_on_rating"
    t.index ["reservation_id"], name: "index_reviews_on_reservation_id"
    t.index ["user_id", "reservation_id"], name: "index_reviews_on_user_id_and_reservation_id", unique: true
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "tables", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.integer "capacity", null: false
    t.string "area", null: false
    t.text "features"
    t.decimal "price_per_person", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area"], name: "index_tables_on_area"
    t.index ["capacity"], name: "index_tables_on_capacity"
    t.index ["name"], name: "index_tables_on_name", unique: true
  end

  create_table "time_slots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "table_id", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.date "date", null: false
    t.boolean "is_available", default: true, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date", "is_available"], name: "index_time_slots_on_date_and_is_available"
    t.index ["date"], name: "index_time_slots_on_date"
    t.index ["table_id", "date", "start_time"], name: "index_time_slots_on_table_id_and_date_and_start_time"
    t.index ["table_id"], name: "index_time_slots_on_table_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "customer", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "reservations", "time_slots"
  add_foreign_key "reservations", "users"
  add_foreign_key "reviews", "reservations"
  add_foreign_key "reviews", "users"
  add_foreign_key "time_slots", "tables"
end
