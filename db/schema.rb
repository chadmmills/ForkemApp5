# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171125140050) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "pgcrypto"

  create_table "grocery_list_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "ingredient_ids", array: true
    t.string "edited_name"
    t.string "orig_name", null: false
    t.uuid "grocery_list_id"
    t.uuid "meal_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_completed", default: false, null: false
    t.index ["grocery_list_id"], name: "index_grocery_list_items_on_grocery_list_id"
    t.index ["meal_id"], name: "index_grocery_list_items_on_meal_id"
  end

  create_table "grocery_lists", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.string "mealbook_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mealbook_id"], name: "index_grocery_lists_on_mealbook_id"
  end

  create_table "ingredients", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "measurement_unit"
    t.decimal "quantity"
    t.uuid "meal_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meal_id"], name: "index_ingredients_on_meal_id"
  end

  create_table "meal_assignments", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.date "assigned_on", null: false
    t.uuid "meal_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", default: 0, null: false
    t.index ["assigned_on", "meal_id"], name: "index_meal_assignments_on_assigned_on_and_meal_id"
    t.index ["meal_id"], name: "index_meal_assignments_on_meal_id"
  end

  create_table "mealbook_users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "mealbook_id"
    t.uuid "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mealbook_id"], name: "index_mealbook_users_on_mealbook_id"
    t.index ["user_id"], name: "index_mealbook_users_on_user_id"
  end

  create_table "mealbooks", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "param", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["param"], name: "index_mealbooks_on_param", unique: true
  end

  create_table "meals", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "desc"
    t.uuid "mealbook_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mealbook_id"], name: "index_meals_on_mealbook_id"
  end

  create_table "users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", null: false
    t.string "name", default: "", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

  add_foreign_key "grocery_list_items", "grocery_lists", on_delete: :cascade
  add_foreign_key "grocery_list_items", "meals", on_delete: :cascade
  add_foreign_key "ingredients", "meals", on_delete: :cascade
  add_foreign_key "meal_assignments", "meals", on_delete: :cascade
  add_foreign_key "mealbook_users", "mealbooks", on_delete: :cascade
  add_foreign_key "mealbook_users", "users", on_delete: :cascade
  add_foreign_key "meals", "mealbooks", on_delete: :cascade
end
