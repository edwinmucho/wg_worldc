# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20180618030437) do

  create_table "buglists", force: :cascade do |t|
    t.string   "user_key",   limit: 255
    t.string   "err_msg",    limit: 255
    t.string   "usr_msg",    limit: 255
    t.string   "mstep",      limit: 255
    t.string   "fstep",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "countries", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "group",      limit: 255
    t.string   "code",       limit: 255
    t.string   "flag_url",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "managers", force: :cascade do |t|
    t.integer  "country_id", limit: 4
    t.string   "name",       limit: 255
    t.string   "pic_url",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "managers", ["country_id"], name: "fk_rails_9b9cf96a41", using: :btree

  create_table "players", force: :cascade do |t|
    t.integer  "country_id", limit: 4
    t.string   "name",       limit: 255
    t.string   "height",     limit: 255
    t.string   "weight",     limit: 255
    t.string   "age",        limit: 255
    t.string   "position",   limit: 255
    t.string   "back_num",   limit: 255
    t.string   "team",       limit: 255
    t.string   "pic_url",    limit: 255
    t.integer  "goal",       limit: 4
    t.integer  "assist",     limit: 4
    t.integer  "y_card",     limit: 4
    t.integer  "r_card",     limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "players", ["country_id"], name: "fk_rails_7965ae0fee", using: :btree

  create_table "tactics", force: :cascade do |t|
    t.integer  "country_id", limit: 4
    t.string   "name",       limit: 255
    t.string   "height",     limit: 255
    t.string   "weight",     limit: 255
    t.string   "age",        limit: 255
    t.string   "position",   limit: 255
    t.string   "back_num",   limit: 255
    t.string   "team",       limit: 255
    t.string   "pic_url",    limit: 255
    t.integer  "goal",       limit: 4
    t.integer  "assist",     limit: 4
    t.integer  "y_card",     limit: 4
    t.integer  "r_card",     limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "tactics", ["country_id"], name: "fk_rails_85d8d6808c", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "user_key",   limit: 255
    t.integer  "chat_room",  limit: 4
    t.integer  "country_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "users", ["country_id"], name: "fk_rails_7325e2cdfa", using: :btree

  add_foreign_key "managers", "countries"
  add_foreign_key "players", "countries"
  add_foreign_key "tactics", "countries"
  add_foreign_key "users", "countries"
end
