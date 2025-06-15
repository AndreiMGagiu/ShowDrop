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

ActiveRecord::Schema[8.0].define(version: 2025_06_15_190359) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "distributors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "country"
    t.string "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_distributors_on_name", unique: true
  end

  create_table "releases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "episode_id", null: false
    t.uuid "tv_show_id", null: false
    t.uuid "distributor_id", null: false
    t.string "episode_name"
    t.date "airdate"
    t.datetime "airstamp"
    t.integer "runtime"
    t.integer "season"
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["distributor_id"], name: "index_releases_on_distributor_id"
    t.index ["episode_id"], name: "index_releases_on_episode_id", unique: true
    t.index ["tv_show_id"], name: "index_releases_on_tv_show_id"
  end

  create_table "tv_shows", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "provider_identifier", null: false
    t.string "name", null: false
    t.string "language", null: false
    t.string "status"
    t.float "rating"
    t.text "summary"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "premiered"
    t.index ["premiered"], name: "index_tv_shows_on_premiered"
    t.index ["provider_identifier"], name: "index_tv_shows_on_provider_identifier", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "releases", "distributors"
  add_foreign_key "releases", "tv_shows"
end
