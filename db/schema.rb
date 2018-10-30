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

ActiveRecord::Schema.define(version: 2018_10_29_130548) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "container_list_document", force: :cascade do |t|
    t.string "dec_code"
    t.string "id_code"
    t.string "institution"
    t.string "description"
    t.string "file_mime"
    t.text "file"
    t.json "signatories"
    t.json "tags"
    t.boolean "busy"
    t.json "related_document"
    t.integer "status"
    t.string "mesaje_status"
    t.integer "id_action"
    t.string "type_action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "logs", force: :cascade do |t|
    t.string "dec_code"
    t.string "id_code"
    t.string "institution"
    t.string "description"
    t.string "file_mime"
    t.text "file"
    t.json "signatories"
    t.json "tags"
    t.boolean "busy"
    t.json "related_document"
    t.integer "status"
    t.string "mesaje_status"
    t.integer "id_action"
    t.string "type_action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "user"
    t.string "password_digest"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
