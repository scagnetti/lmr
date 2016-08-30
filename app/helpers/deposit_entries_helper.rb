module DepositEntriesHelper

  def calc_balance(deposit_entry)
      return get_sell_volume(deposit_entry) - get_buy_volume(deposit_entry)
  end

  def get_balance_for_display(deposit_entry)
    if deposit_entry.sell_transaction.nil?
      return ""
    else
      "%.2f" % calc_balance(deposit_entry)
    end
  end

  def do_highlight(deposit_entry)
    if deposit_entry.sell_transaction != nil
      value = deposit_entry.sell_transaction.price - deposit_entry.buy_transaction.price
      if value > 0
        return "success"
      else
        return "bg-danger"
      end
    else
      return ""
    end
  end

  def get_buy_volume(deposit_entry)
    return deposit_entry.buy_transaction.price * deposit_entry.buy_transaction.amount
  end

  def get_sell_volume(deposit_entry)
    if deposit_entry.sell_transaction.nil?
      return 0
    else
      return deposit_entry.sell_transaction.price * deposit_entry.sell_transaction.amount
    end
  end

  def total_balance()
    sum = 0
    @deposit_entries.each do |deposit_entry|
      if deposit_entry.archived
        sum = sum + calc_balance(deposit_entry)
        sum = sum - deposit_entry.buy_transaction.fees
        if deposit_entry.sell_transaction != nil
          sum = sum - deposit_entry.sell_transaction.fees
        end
      end
    end
    return sum
  end

end
