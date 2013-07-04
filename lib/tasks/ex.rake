require 'mechanize'
require 'engine/extractor/finanzen_extractor.rb'
require 'engine/extractor/on_vista_extractor.rb'
require 'engine/exceptions/data_mining_error.rb'
require 'engine/stock_processor.rb'


namespace :ex do

  desc "Extract the reaction on quarterly figures"
  task :reaction_stock => :environment do
    # e = OnVistaExtractor.new('US0378331005','US2605661048')
    # e = FinanzenExtractor.new('US0378331005','US2605661048')
    # e.extract_reaction_on_figures('US2605661048', Reaction.new)
    e = FinanzenExtractor.new('DE0007037129',' DE0008469008')
    e.extract_reaction_on_figures(' DE0008469008', Reaction.new)
  end

  desc "Extract the return on equity (Eigenkapitalrendite)"  
  task :roe_stock => :environment do
    e = OnVistaExtractor.new('DE0007037129','DE0008469008')
    e.extract_roe(ReturnOnEquity.new)
  end
  
  desc "Extract the EBIT margin"
  task :ebit_margin_stock => :environment do
    e = OnVistaExtractor.new('DE0007037129','DE0008469008')
    e.extract_ebit_margin(EbitMargin.new)
  end
  
  desc "Extract the equity ratio (Eigenkapital)"
  task :equity_ratio_stock => :environment do
    e = OnVistaExtractor.new('DE0007037129','DE0008469008')
    e.extract_equity_ratio(EquityRatio.new)
  end
  
  desc "Try to add all shares of agiven index"
  task :add_shares => :environment do
    @agent = Mechanize.new
    @page = @agent.get('http://www.finanzen.net/index/DAX')
    tag_set = @page.parser().xpath("//h2[.='DAX']/../following-sibling::div/table/tr[position()>1]")
    tag_set.each do |tr|
      td_set = tr.xpath("child::node()")
      content = td_set[0].text()
      isin = content[-12,12]
      name = td_set[0].xpath("a").first
      puts "Name #{name.content} ISIN: #{isin}"
      #TODO Create a share object
    end
  end
  
  desc "Try to rate all available stocks"
  task :rate_all => :environment do
    failed = Array.new
    isin_dax = 'DE0008469008'
    shares = Share.where('active' => true)
    shares.each do |s|
      begin
        @score_card = ScoreCard.new()
        @score_card.share = s
        # Run the algorithm
        stock_processor = StockProcessor.new(@score_card)
        stock_processor.go()
        @score_card.save
      rescue DataMiningError
        failed << isin
      end
    end
    #Show stocks failed to extract reaction on quarterly figures
    puts "No reaction could be extracted for the following #{failed.size} stocks:"
    failed.each do |isin|
      puts "#{isin} - FAILED"
    end
  end
  
  desc "Extract known insider deals"
  task :insider => :environment do
    isin_dax = 'DE0008469008'
    @agent = Mechanize.new
    @page = @agent.get('http://www.finanzen.net/index/DAX')
    tag_set = @page.parser().xpath("//h2[.='DAX']/../following-sibling::div/table/tr[position()>1]")
    tag_set.each do |tr|
      td_set = tr.xpath("child::node()")
      content = td_set[0].text()
      isin = content[-12,12]
      puts "\nUsing: #{isin}"
      e = FinanzenExtractor.new(isin,' DE0008469008')
      e.extract_insider_deals()
    end
  end
  
  task :t => :environment do
    e = FinanzenExtractor.new('DE0007037129',' DE0008469008')
    e.extract_insider_deals()
    
  end
  
end
