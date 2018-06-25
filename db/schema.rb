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

ActiveRecord::Schema.define(version: 20180621171139) do

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

  create_table "forecasts", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "game_id",    limit: 4
    t.string   "f_home",     limit: 255
    t.string   "f_away",     limit: 255
    t.string   "f_guess",    limit: 255
    t.integer  "f_hs",       limit: 4
    t.integer  "f_as",       limit: 4
    t.boolean  "ispredict"
    t.integer  "get_point",  limit: 4,   default: 0
    t.integer  "get_alpha",  limit: 4
    t.integer  "corr_count", limit: 4,   default: 0
    t.boolean  "isapply"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "forecasts", ["game_id"], name: "fk_rails_fc6a9d4360", using: :btree
  add_index "forecasts", ["user_id"], name: "fk_rails_69c972f93b", using: :btree

  create_table "games", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.string   "home",       limit: 255
    t.string   "away",       limit: 255
    t.string   "game_date",  limit: 255
    t.string   "game_time",  limit: 255
    t.string   "game_state", limit: 255
    t.string   "result",     limit: 255
    t.integer  "r_hs",       limit: 4
    t.integer  "r_as",       limit: 4
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
    t.string   "nick",       limit: 255
    t.integer  "point",      limit: 4
  end

  add_index "users", ["country_id"], name: "fk_rails_7325e2cdfa", using: :btree

  add_foreign_key "forecasts", "games"
  add_foreign_key "forecasts", "users"
  add_foreign_key "managers", "countries"
  add_foreign_key "players", "countries"
  add_foreign_key "tactics", "countries"
  add_foreign_key "users", "countries"
end
