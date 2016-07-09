require 'mechanize'
require 'robot/boerse_ard.rb'

namespace :roboto do

  task :t => :environment do
    browser = Watir::Browser.new
    browser.goto("http://www.w3schools.com/")
    #td_set = browser.elements(:xpath, '//td')
    td_set = browser.tds(:xpath, '//td')
    puts td_set.size
    td_set.each do |td|
      puts td.text()
    end
  end

  task :test => :environment do
    # For simple testing only
    roboto = BoerseArd.new
    roboto.login()
    isin_list = roboto.list('lmr')
    isin_list.each do |isin|
      puts isin
    end
    #roboto.logout()
  end
  
  desc "Let Mr. Roboto buy a share"
  task :buy, [:isin, :portfolio] => :environment do |t, args|
    if args.isin.nil? || args.portfolio.nil?
      puts "Usage: rake roboto:buy <isin> <portfolio>"
      exit
    end

    isin = args[:isin]
    portfolio = args[:portfolio]
    roboto = BoerseArd.new
    roboto.login()
    roboto.buy(isin, portfolio)
    roboto.logout()
  end

  desc "Update a portfolio (buy good shares, sell bad shares)"
  task :update_portfolio, [:portfolio] => :environment do |t, args|
    if args.portfolio.nil?
      puts "Usage: rake roboto:update_portfolio <portfolio>"
      exit
    end

    portfolio = args[:portfolio]
    recommended_shares = ScoreCard.joins(share: :stock_index).where('total_score > 3 AND stock_indices.name LIKE ? AND score_cards.created_at BETWEEN ? AND ?', 'Dax', Date.today, Date.today + 1)
    recommended_list = recommended_shares.collect {|sc| sc.share.isin}

    puts "Levermann recommends #{recommended_list.size} share(s) for buying..."

    roboto = BoerseArd.new
    roboto.login()
    owning_list = roboto.list(portfolio)

    buy = Array.new
    recommended_list.each do |e|
      unless owning_list.include?(e)
        buy << e
      end
    end

    sell = Array.new
    owning_list.each do |e|
      unless recommended_list.include?(e)
        sell << e
      end
    end

    buy.each do |isin|
      roboto.buy(isin, portfolio)
    end

    sell.each do |isin|
      roboto.sell(isin, portfolio)
    end

    roboto.logout()

    puts "Here you go."
  end

end
