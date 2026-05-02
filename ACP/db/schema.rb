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

ActiveRecord::Schema[7.2].define(version: 2026_05_01_104203) do
  create_table "active_storage_attachments", charset: "utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", charset: "utf8", force: :cascade do |t|
    t.string "name_th"
    t.string "name_en"
    t.string "code"
    t.bigint "category_group_id", null: false
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_group_id"], name: "index_categories_on_category_group_id"
  end

  create_table "category_groups", charset: "utf8", force: :cascade do |t|
    t.string "name_th"
    t.string "name_en"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "galleries", charset: "utf8", force: :cascade do |t|
    t.string "image"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "registrations", charset: "utf8", force: :cascade do |t|
    t.string "name_th"
    t.string "name_en"
    t.string "category"
    t.string "district"
    t.string "province"
    t.string "phone"
    t.string "email"
    t.string "song"
    t.integer "duration"
    t.string "competition_type"
    t.integer "price"
    t.integer "vat"
    t.integer "total"
    t.integer "status", limit: 3
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
    t.integer "song_status"
  end

  create_table "score_categories", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.integer "max_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scores", charset: "utf8", force: :cascade do |t|
    t.bigint "registration_id", null: false
    t.bigint "user_id", null: false
    t.bigint "score_category_id", null: false
    t.integer "value"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["registration_id"], name: "index_scores_on_registration_id"
    t.index ["score_category_id"], name: "index_scores_on_score_category_id"
    t.index ["user_id"], name: "index_scores_on_user_id"
  end

  create_table "settings", charset: "utf8", force: :cascade do |t|
    t.text "terms_th"
    t.text "terms_en"
    t.text "rules_online_th"
    t.text "rules_online_en"
    t.text "rules_onsite_th"
    t.text "rules_onsite_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.string "firstname"
    t.string "lastname"
    t.string "telephone"
    t.string "email"
    t.integer "status", limit: 3
    t.integer "role", limit: 3
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "categories", "category_groups"
  add_foreign_key "scores", "registrations"
  add_foreign_key "scores", "score_categories"
  add_foreign_key "scores", "users"
end
