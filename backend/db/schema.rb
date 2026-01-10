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

ActiveRecord::Schema[7.2].define(version: 2026_01_10_031640) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "external_identities", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.string "source", null: false
    t.string "external_id", null: false
    t.string "email", null: false
    t.string "department"
    t.jsonb "metadata", default: {}
    t.datetime "external_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department"], name: "index_external_identities_on_department"
    t.index ["email", "source"], name: "index_external_identities_on_email_and_source", unique: true
    t.index ["email"], name: "index_external_identities_on_email"
    t.index ["person_id"], name: "index_external_identities_on_person_id"
    t.index ["source", "external_id"], name: "index_external_identities_on_source_and_external_id", unique: true
    t.index ["source"], name: "index_external_identities_on_source"
  end

  create_table "people", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "external_identities", "people"
end
