class DepositEntry < ActiveRecord::Base
  belongs_to :share
  has_one :buy_transaction, autosave: true
  has_one :sell_transaction, autosave: true
end
