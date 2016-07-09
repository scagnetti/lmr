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

ActiveRecord::Schema.define(version: 20150531154700) do

  create_table "analysts_opinions", force: :cascade do |t|
    t.boolean  "succeeded",     default: true
    t.integer  "score",         default: -1
    t.text     "error_msg"
    t.integer  "buy",           default: -1
    t.integer  "hold",          default: -1
    t.integer  "sell",          default: -1
    t.integer  "score_card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "analysts_opinions", ["score_card_id"], name: "index_analysts_opinions_on_score_card_id"

  create_table "average_price_earnings_ratios", force: :cascade do |t|
    t.boolean  "succeeded",             default: true
    t.integer  "score",                 default: -1
    t.text     "error_msg"
    t.integer  "three_years_ago",       default: -1
    t.integer  "two_years_ago",         default: -1
    t.integer  "last_year",             default: -1
    t.integer  "this_year",             default: -1
    t.integer  "next_year",             default: -1
    t.float    "average"
    t.float    "value_three_years_ago", default: -1.0
    t.float    "value_two_years_ago",   default: -1.0
    t.float    "value_last_year",       default: -1.0
    t.float    "value_this_year",       default: -1.0
    t.float    "value_next_year",       default: -1.0
    t.integer  "score_card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "average_price_earnings_ratios", ["score_card_id"], name: "index_average_price_earnings_ratios_on_score_card_id"

  create_table "current_price_earnings_ratios", force: :cascade do |t|
    t.boolean  "succeeded",     default: true
    t.integer  "score",         default: -1
    t.text     "error_msg"
    t.integer  "this_year",     default: -1
    t.float    "value",         default: -1.0
    t.integer  "score_card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "current_price_earnings_ratios", ["score_card_id"], name: "index_current_price_earnings_ratios_on_score_card_id"

  create_table "ebit_margins", force: :cascade do |t|
    t.boolean  "succeeded",     default: true
    t.integer  "score",         default: -1
    t.text     "error_msg"
    t.integer  "last_year",     default: -1
    t.float    "value",         default: -1.0
    t.integer  "score_card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ebit_margins", ["score_card_id"], name: "index_ebit_margins_on_score_card_id"

  create_table "equity_ratios", force: :cascade do |t|
    t.boolean  "succeeded",     default: true
    t.integer  "score",         default: -1
    t.text     "error_msg"
    t.integer  "last_year",     default: -1
    t.float    "value",         default: -1.0
    t.integer  "score_card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "equity_ratios", ["score_card_id"], name: "index_equity_ratios_on_score_card_id"

  create_table "insider_deals", force: :cascade do |t|
    t.date     "occurred"
    t.string   "person"
    t.integer  "quantity"
    t.float    "price"
    t.integer  "transaction_type", default: 0
    t.string   "link"
    t.integer  "insider_info_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "insider_deals", ["insider_info_id"], name: "index_insider_deals_on_insider_info_id"

  create_table "insider_infos", force: :cascade do |t|
    t.boolean  "succeeded",     default: true
    t.integer  "score",         default: -1
    t.text     "error_msg"
    t.integer  "score_card_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "insider_infos", ["score_card_id"], name: "index_insider_infos_on_score_card_id"

  create_table "momenta", force: :cascade do |t|
    t.boolean  "succeeded",                    default: true
    t.integer  "score",                        default: -1
    t.text     "error_msg"
    t.integer  "stock_price_dev_half_year_id"
    t.integer  "stock_price_dev_one_year_id"
    t.integer  "score_card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "momenta", ["score_card_id"], name: "index_momenta_on_score_card_id"

  create_table "person_of_interests", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profit_growths", force: :cascade do |t|
    t.boolean  "succeeded",       default: true
    t.integer  "score",           default: -1
    t.text     "error_msg"
    t.integer  "this_year",       default: -1
    t.integer  "next_year",       default: -1
    t.float    "value_this_year", default: -1.0
    t.float    "value_next_year", default: -1.0
    t.float    "perf"
    t.integer  "score_card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profit_growths", ["score_card_id"], name: "index_profit_growths_on_score_card_id"

  create_table "profit_revisions", force: :cascade do |t|
    t.boolean  "succeeded",     default: true
    t.integer  "score",         default: -1
    t.text     "error_msg"
    t.integer  "up",            default: -1
    t.integer  "equal",         default: -1
    t.integer  "down",          default: -1
    t.integer  "score_card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profit_revisions", ["score_card_id"], name: "index_profit_revisions_on_score_card_id"

  create_table "reactions", force: :cascade do |t|
    t.boolean  "succeeded",     default: true
    t.integer  "score",         default: -1
    t.text     "error_msg"
    t.date     "release_date"
    t.date     "before"
    t.date     "after"
    t.float    "price_before",  default: -1.0
    t.float    "price_after",   default: -1.0
    t.float    "index_before",  default: -1.0
    t.float    "index_after",   default: -1.0
    t.float    "share_perf",    default: -1.0
    t.float    "index_perf",    default: -1.0
    t.integer  "score_card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reactions", ["score_card_id"], name: "index_reactions_on_score_card_id"

  create_table "return_on_equities", force: :cascade do |t|
    t.boolean  "succeeded",     default: true
    t.integer  "score",         default: -1
    t.text     "error_msg"
    t.integer  "last_year",     default: -1
    t.float    "value",         default: -1.0
    t.integer  "score_card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "return_on_equities", ["score_card_id"], name: "index_return_on_equities_on_score_card_id"

  create_table "reversals", force: :cascade do |t|
    t.boolean  "succeeded",                   default: true
    t.integer  "score",                       default: -1
    t.text     "error_msg"
    t.date     "four_months_ago"
    t.date     "three_months_ago"
    t.date     "two_months_ago"
    t.date     "one_month_ago"
    t.float    "value_four_months_ago",       default: -1.0
    t.float    "value_three_months_ago",      default: -1.0
    t.float    "value_two_months_ago",        default: -1.0
    t.float    "value_one_month_ago",         default: -1.0
    t.float    "value_perf_three_months_ago"
    t.float    "value_perf_two_months_ago"
    t.float    "value_perf_one_month_ago"
    t.float    "index_four_months_ago",       default: -1.0
    t.float    "index_three_months_ago",      default: -1.0
    t.float    "index_two_months_ago",        default: -1.0
    t.float    "index_one_month_ago",         default: -1.0
    t.float    "index_perf_three_months_ago"
    t.float    "index_perf_two_months_ago"
    t.float    "index_perf_one_month_ago"
    t.integer  "score_card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reversals", ["score_card_id"], name: "index_reversals_on_score_card_id"

  create_table "rising_scores", force: :cascade do |t|
    t.integer  "share_id"
    t.integer  "days"
    t.string   "isin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "score_cards", force: :cascade do |t|
    t.integer  "share_id"
    t.float    "price"
    t.string   "currency"
    t.integer  "total_score", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shares", force: :cascade do |t|
    t.boolean  "active",                     default: true
    t.string   "name",           limit: 255,                null: false
    t.string   "isin",           limit: 255,                null: false
    t.boolean  "financial"
    t.integer  "size"
    t.string   "stock_exchange", limit: 255
    t.string   "currency",       limit: 255
    t.integer  "stock_index_id"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "stock_indices", force: :cascade do |t|
    t.string   "isin",       limit: 255, null: false
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "stock_price_dev_half_years", force: :cascade do |t|
    t.boolean  "succeeded",       default: true
    t.integer  "score",           default: -1
    t.text     "error_msg"
    t.float    "compare",         default: -1.0
    t.float    "value",           default: -1.0
    t.date     "historical_date"
    t.float    "perf"
    t.integer  "score_card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stock_price_dev_half_years", ["score_card_id"], name: "index_stock_price_dev_half_years_on_score_card_id"

  create_table "stock_price_dev_one_years", force: :cascade do |t|
    t.boolean  "succeeded",       default: true
    t.integer  "score",           default: -1
    t.text     "error_msg"
    t.float    "compare",         default: -1.0
    t.float    "value",           default: -1.0
    t.date     "historical_date"
    t.float    "perf"
    t.integer  "score_card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stock_price_dev_one_years", ["score_card_id"], name: "index_stock_price_dev_one_years_on_score_card_id"

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.boolean  "admin"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
