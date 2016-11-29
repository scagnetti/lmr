namespace :broker do

  task :check_deposit, [:a,:b] => :environment do |t, args|
    puts "Parameter a: #{args[:a]}"
    puts "Parameter b: #{args[:b]}"

    # Which shares have a buy recommendation today?

    if Rails.env == 'production'
      recommendations = ScoreCard.joins(share: :stock_index).where('total_score > 3 AND score_cards.created_at BETWEEN ? AND ?', Date.today, Date.today + 1)
    else
      recommendations = ScoreCard.joins(share: :stock_index).where('total_score > 3 AND stock_indices.name LIKE ?', 'Dax')
    end
    
    puts "Levermann recommends #{recommendations.size} dax share(s) for buying"
    #recommendations.each do |sc|
    #  puts "Rating: #{sc.total_score}, Share: #{sc.share.name}"
    #end
    
    recommendations.each do |sc|
      de = DepositEntry.find_by(share_id: sc.share.id)
      if de.nil?
        puts "Going to buy share #{sc.share.name} because it is not yet in the deposit"
        
        transaction = BuyTransaction.new
        transaction.occurred = Date.today
        transaction.price = sc.price
        # TODO if necessary convert to EUR
        # curl "https://www.google.com/finance/converter?a=212&from=USD&to=EUR" | grep id=currency_converter_result
        transaction.currency = sc.currency
        transaction.amount = get_quantity_to_buy(4000, transaction.price)
        transaction.fees = 10

        entry = DepositEntry.new
        entry.share = sc.share
        entry.buy_transaction = transaction
        entry.save
      else
        puts "Nothing to do for #{sc.share.name}. Deposit already contains this share"
      end
    end
    
    puts "Checking if some shares have to be sold, due to a fallen rating"
    # Which shares are in the deposit but don't have a buy recommenadtion any more?
    DepositEntry.where(archived: false).each do |entry|
      if Rails.env == 'production'
        sc = ScoreCard.find_by("share_id = ? AND created_at BETWEEN ? AND ?", entry.share.id, Date.today, Date.today + 1)
      else
        sc = ScoreCard.where("share_id = ?", entry.share.id).group("share_id").first
      end
      if sc != nil && sc.total_score < 4
        puts "Selling share #{sc.share.name}, because its rating (#{sc.total_score}) droped under the threshold"

        transaction = SellTransaction.new
        transaction.occurred = Date.today
        transaction.price = sc.price
        # TODO if necessary convert to EUR
        # curl "https://www.google.com/finance/converter?a=212&from=USD&to=EUR" | grep id=currency_converter_result
        transaction.currency = sc.currency
        transaction.amount = entry.buy_transaction.amount
        transaction.fees = 10

        entry.balance = (transaction.price * transaction.amount) - transaction.fees - entry.buy_transaction.fees - (entry.buy_transaction.price * entry.buy_transaction.amount)
        entry.sell_transaction = transaction
        entry.archived = true
        entry.save
      end
    end
  end

  def get_quantity_to_buy(volume, price)
    return volume / price
  end
end