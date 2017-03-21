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

ActiveRecord::Schema.define(version: 20170321021638) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "ingredients", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name",             null: false
    t.string   "measurement_unit"
    t.decimal  "quantity"
    t.uuid     "meal_id",          null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["meal_id"], name: "index_ingredients_on_meal_id", using: :btree
  end

  create_table "meal_assignments", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.date     "assigned_on", null: false
    t.uuid     "meal_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["assigned_on", "meal_id"], name: "index_meal_assignments_on_assigned_on_and_meal_id", unique: true, using: :btree
    t.index ["meal_id"], name: "index_meal_assignments_on_meal_id", using: :btree
  end

  create_table "mealbooks", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "param",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["param"], name: "index_mealbooks_on_param", unique: true, using: :btree
  end

  create_table "meals", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name",        null: false
    t.string   "desc"
    t.uuid     "mealbook_id", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["mealbook_id"], name: "index_meals_on_mealbook_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "email",                                       null: false
    t.string   "name",                           default: "", null: false
    t.string   "encrypted_password", limit: 128,              null: false
    t.string   "confirmation_token", limit: 128
    t.string   "remember_token",     limit: 128,              null: false
    t.index ["email"], name: "index_users_on_email", using: :btree
    t.index ["remember_token"], name: "index_users_on_remember_token", using: :btree
  end

  add_foreign_key "ingredients", "meals", on_delete: :cascade
  add_foreign_key "meal_assignments", "meals", on_delete: :cascade
  add_foreign_key "meals", "mealbooks", on_delete: :cascade
end
