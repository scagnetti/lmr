class Reversal < ActiveRecord::Base
  attr_accessible :error_msg, :four_month_ago, :one_month_ago, :succeeded, :three_month_ago, :two_month_ago
  has_many :score_cards
end
