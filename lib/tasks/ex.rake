require 'mechanize'
require 'engine/extractor/finanzen_extractor.rb'
require 'engine/extractor/on_vista_extractor.rb'
require 'engine/exceptions/data_mining_error.rb'
require 'engine/stock_processor.rb'

namespace :ex do

  task :test => :environment do
    # For simple testing only
  end
  
  desc "Extract the onVista stock exchange ID"
  task :stock_exchange_id => :environment do
    s = Share.where("name like ?", 'Volk%').first
    e = OnVistaExtractor.new(s)
    e.stock_value_extractor.get_stock_exchange_id()
  end
  
  desc "Extract the onVista asset name for a stock"
  task :stock_asset_name => :environment do
    s = Share.where("name like ?", 'Volk%').first
    e = OnVistaExtractor.new(s)
    e.stock_value_extractor.get_asset_name()
  end

  desc "Extract the current stock price"
  task :stock_price => :environment do
    s = Share.where("name like ?", 'Volk%').first
    e = OnVistaExtractor.new(s)
    e.extract_stock_price()
  end

  desc "Extract stock price at historical date"
  task :historical_stock_price => :environment do
    s = Share.where("name like ?", 'Volk%').first
    e = OnVistaExtractor.new(s)
    e.stock_value_extractor.extract_stock_value_on("16.12.2013")
  end
  
  #=====================
  #===Levermann Rules===
  #=====================

  desc "Extract the return on equity (Eigenkapitalrendite)"  
  task :roe => :environment do
    s = Share.where("name like ?", 'Volk%').first
    e = OnVistaExtractor.new(s)
    e.extract_roe(ReturnOnEquity.new)
  end
  
  desc "Extract the EBIT margin"
  task :ebit_margin => :environment do
    s = Share.where("name like ?", 'Volk%').first
    e = OnVistaExtractor.new(s)
    e.extract_ebit_margin(EbitMargin.new)
  end

  desc "Extract the equity ratio (Eigenkapital)"
  task :equity_ratio => :environment do
    s = Share.where("name like ?", 'Volk%').first
    e = OnVistaExtractor.new(s)
    e.extract_equity_ratio(EquityRatio.new)
  end

  desc "Extract the current price earnings ratio (KGV)"
  task :price_earnings_ratio => :environment do
    s = Share.where("name like ?", 'BMW').first
    e = OnVistaExtractor.new(s)
    e.extract_current_price_earnings_ratio(CurrentPriceEarningsRatio.new)
  end

  desc "Extract the average price earnings ratio (KGV 5)"
  task :avg_price_earnings_ratio => :environment do
    s = Share.where("name like ?", 'BMW').first
    e = OnVistaExtractor.new(s)
    e.extract_average_price_earnings_ratio(AveragePriceEarningsRatio.new)
  end

  desc "Extract Analysts Opinion"
  task :analyst, [:isin] => :environment do |t, args|
    isin = args[:isin]
    s = Share.where("name like ?", 'Volk%').first
    e = OnVistaExtractor.new(s)
    e.extract_analysts_opinion(AnalystsOpinion.new)
  end
  
  desc "Extract the reaction on quarterly figures"
  task :reaction => :environment do
    s = Share.where("name like ?", 'Volk%').first
    e = OnVistaExtractor.new(s)
    e.extract_reaction_on_figures(Reaction.new)
  end

  desc "Extract the profit growth"
  task :profit_growth => :environment do
    s = Share.where("name like ?", 'Volk%').first
    e = OnVistaExtractor.new(s)
    e.extract_profit_growth(ProfitGrowth.new)
  end
  
  desc "Extract the profit revision"
  task :profit_revision => :environment do
    s = Share.where("name like ?", 'Volk%').first
    e = OnVistaExtractor.new(s)
    e.extract_profit_revision(ProfitRevision.new)
  end

  #======================================================
  #===Deprecated way of populating Share database     ===
  #===The Stock Exchangs has to be set individualy!   ===
  #======================================================
  desc "Add all shares of a given index (ISIN) to databse. Default index is DAX."
  task :add_shares, [:index_isin] => :environment do |t, args|
    # Set a default value for the parameter
    args.with_defaults(:index_isin => 'DE0008469008')
    indices = StockIndex.where('isin' => args[:index_isin])
    puts "#{indices.class}"
    if indices.empty?
      puts "No matching stock index found for '#{args[:index_isin]}'"
    else
      puts "Extracting shares for index '#{indices.first.name}'"
      @agent = Mechanize.new
      @page = @agent.get('http://www.finanzen.net/index/DAX')
      tag_set = @page.parser().xpath("(//h2[.='DAX 30'])[1]/../following-sibling::div/table//tr/td[1]")
      tag_set.each do |td|
        isin = td.xpath("text()").first.content()
        name = td.xpath("a").first.content()
        puts "Adding #{isin} - #{name}"
        share = Share.new
        share.name = name
        share.isin = isin
        share.active = true
        share.financial = false
        share.stock_index = indices.first
        share.size = CompanySize::LARGE
        share.stock_exchange = 'Tradegate'
        share.save
      end
    end
  end
  
  #======================
  #===Task for Cronjob===
  #======================
  
  desc "Try to rate a specific share"
  task :rate_one => :environment do 
    failed = Array.new
    s = Share.where("isin = ?", "US0970231058").first
    score_card = ScoreCard.new()
    score_card.share = s
    begin
      # Run the algorithm
      stock_processor = StockProcessor.new(score_card)
      stock_processor.go()
      score_card.save
    rescue DataMiningError
      failed << s
    end

    #Show stocks with problems
    puts "For the following share, problems occured during the evaluation:"
    failed.each do |f|
      puts "#{f.name} - FAILED"
    end
  end
  
  desc "Try to rate all available stocks"
  task :rate_all => :environment do 
    t1 = Time.now
    failed = Array.new
    shares = Share.where('active' => true)
    shares.each do |s|
      begin
        score_card = ScoreCard.new()
        score_card.share = s
        # Run the algorithm
        stock_processor = StockProcessor.new(score_card)
        stock_processor.go()
        score_card.save
      rescue DataMiningError
        failed << s
      end
    end
    t2 = Time.now
    diff_seconds = t2 - t1
    min = diff_seconds / 60
    sec = diff_seconds % 60
    puts "The evaluation tool #{min} minutes and #{sec} seconds"
    #Show stocks with problems
    puts "For the following shares, problems occured during the evaluation:"
    failed.each do |s|
      puts "#{s.name} - FAILED"
    end
  end
  
  #====================
  #===Indsider Deals===
  #====================
  
  desc "Extract known insider deals inside the DAX index"
  task :insider_dax => :environment do
    isin_dax = 'DE0008469008'
    @agent = Mechanize.new
    @page = @agent.get('http://www.finanzen.net/index/DAX')
    tag_set = @page.parser().xpath("(//h2[.='DAX 30'])[1]/../following-sibling::div/table/tr[position()>1]")
    tag_set.each do |tr|
      td_set = tr.xpath("child::node()")
      content = td_set[0].text()
      isin = content[-12,12]
      puts "\nUsing: #{isin}"
      e = FinanzenExtractor.new(isin, INDEX_ISIN, STOCK_EXCHANGE)
      e.extract_insider_deals(Array.new)
    end
  end
  
  desc "Extract DAX Insider Deals of the last three months for a given ISIN"
  task :insider, [:isin] => :environment do |t, args|
    if args[:isin] == nil
      isin = STOCK_ISIN
    else
      isin = args[:isin]
    end
    e = FinanzenExtractor.new(isin, INDEX_ISIN, STOCK_EXCHANGE)
    e.extract_insider_deals(Array.new)
  end
  
end
