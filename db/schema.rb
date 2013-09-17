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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130915064946) do

  create_table "analysts_opinions", :force => true do |t|
    t.boolean  "succeeded",  :default => true
    t.integer  "score",      :default => -1
    t.text     "error_msg"
    t.integer  "buy"
    t.integer  "hold"
    t.integer  "sell"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "average_price_earnings_ratios", :force => true do |t|
    t.boolean  "succeeded",             :default => true
    t.integer  "score",                 :default => -1
    t.text     "error_msg"
    t.integer  "three_years_ago"
    t.integer  "two_years_ago"
    t.integer  "last_year"
    t.integer  "this_year"
    t.integer  "next_year"
    t.float    "average"
    t.float    "value_three_years_ago"
    t.float    "value_two_years_ago"
    t.float    "value_last_year"
    t.float    "value_this_year"
    t.float    "value_next_year"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "current_price_earnings_ratios", :force => true do |t|
    t.boolean  "succeeded",  :default => true
    t.integer  "score",      :default => -1
    t.text     "error_msg"
    t.integer  "this_year"
    t.float    "value"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "ebit_margins", :force => true do |t|
    t.boolean  "succeeded",  :default => true
    t.integer  "score",      :default => -1
    t.text     "error_msg"
    t.integer  "last_year"
    t.float    "value"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "equity_ratios", :force => true do |t|
    t.boolean  "succeeded",  :default => true
    t.integer  "score",      :default => -1
    t.text     "error_msg"
    t.integer  "last_year"
    t.float    "value"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "insider_deals", :force => true do |t|
    t.integer  "share_id"
    t.date     "occurred"
    t.string   "person"
    t.integer  "quantity"
    t.float    "price"
    t.integer  "trade_type"
    t.string   "link"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "momenta", :force => true do |t|
    t.boolean  "succeeded",                    :default => true
    t.integer  "score",                        :default => -1
    t.text     "error_msg"
    t.integer  "stock_price_dev_half_year_id"
    t.integer  "stock_price_dev_one_year_id"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  create_table "profit_growths", :force => true do |t|
    t.boolean  "succeeded",       :default => true
    t.integer  "score",           :default => -1
    t.text     "error_msg"
    t.date     "this_year"
    t.date     "next_year"
    t.float    "value_this_year"
    t.float    "value_next_year"
    t.float    "perf"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "profit_revisions", :force => true do |t|
    t.boolean  "succeeded",  :default => true
    t.integer  "score",      :default => -1
    t.text     "error_msg"
    t.integer  "up"
    t.integer  "equal"
    t.integer  "down"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "reactions", :force => true do |t|
    t.boolean  "succeeded",     :default => true
    t.integer  "score",         :default => -1
    t.text     "error_msg"
    t.date     "release_date"
    t.float    "price_opening"
    t.float    "price_closing"
    t.float    "index_opening"
    t.float    "index_closing"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "return_on_equities", :force => true do |t|
    t.boolean  "succeeded",  :default => true
    t.integer  "score",      :default => -1
    t.text     "error_msg"
    t.integer  "last_year"
    t.float    "value"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "reversals", :force => true do |t|
    t.boolean  "succeeded",                   :default => true
    t.integer  "score",                       :default => -1
    t.text     "error_msg"
    t.date     "four_months_ago"
    t.date     "three_months_ago"
    t.date     "two_months_ago"
    t.date     "one_month_ago"
    t.float    "value_four_months_ago"
    t.float    "value_three_months_ago"
    t.float    "value_two_months_ago"
    t.float    "value_one_month_ago"
    t.float    "value_perf_three_months_ago"
    t.float    "value_perf_two_months_ago"
    t.float    "value_perf_one_month_ago"
    t.float    "index_four_months_ago"
    t.float    "index_three_months_ago"
    t.float    "index_two_months_ago"
    t.float    "index_one_month_ago"
    t.float    "index_perf_three_months_ago"
    t.float    "index_perf_two_months_ago"
    t.float    "index_perf_one_month_ago"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  create_table "score_cards", :force => true do |t|
    t.integer  "share_id"
    t.float    "price"
    t.integer  "total_score",                     :default => 0
    t.integer  "return_on_equity_id"
    t.integer  "ebit_margin_id"
    t.integer  "equity_ratio_id"
    t.integer  "current_price_earnings_ratio_id"
    t.integer  "average_price_earnings_ratio_id"
    t.integer  "analysts_opinion_id"
    t.integer  "reaction_id"
    t.integer  "profit_revision_id"
    t.integer  "stock_price_dev_half_year_id"
    t.integer  "stock_price_dev_one_year_id"
    t.integer  "momentum_id"
    t.integer  "reversal_id"
    t.integer  "profit_growth_id"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  create_table "shares", :force => true do |t|
    t.boolean  "active",         :default => true
    t.string   "name",                             :null => false
    t.string   "isin",                             :null => false
    t.boolean  "financial"
    t.integer  "size"
    t.date     "asm"
    t.integer  "stock_index_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "stock_indices", :force => true do |t|
    t.string   "isin",       :null => false
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "stock_price_dev_half_years", :force => true do |t|
    t.boolean  "succeeded",  :default => true
    t.integer  "score",      :default => -1
    t.text     "error_msg"
    t.float    "compare"
    t.float    "value"
    t.float    "perf"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "stock_price_dev_one_years", :force => true do |t|
    t.boolean  "succeeded",  :default => true
    t.integer  "score",      :default => -1
    t.text     "error_msg"
    t.float    "compare"
    t.float    "value"
    t.float    "perf"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

end
