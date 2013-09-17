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
  
  desc "Add all shares of a given index (ISIN). Default index is DAX."
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
      tag_set = @page.parser().xpath("//h2[.='DAX']/../following-sibling::div/table/tr[position()>1]")
      tag_set.each do |tr|
        td_set = tr.xpath("child::node()")
        content = td_set[0].text()
        isin = content[-12,12]
        name = td_set[0].xpath("a").first
        puts "Adding #{isin} - #{name.content}"
        share = Share.new
        share.name = name.content
        share.isin = isin
        share.active = true
        share.financial = false
        share.stock_index = indices.first
        share.size = CompanySize::LARGE
        share.save
      end
    end
  end
  
  desc "Try to rate all available stocks"
  task :rate_all => :environment do 
    failed = Array.new
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
        failed << s
      end
    end
    #Show stocks with problems
    puts "For the following share, problems occured during the evaluation:"
    failed.each do |s|
      puts "#{s.name} - FAILED"
    end
  end
  
  desc "Extract known insider deals"
  task :insider => :environment do
    isin_dax = 'DE0008469008'
    @agent = Mechanize.new
    @page = @agent.get('http://www.finanzen.net/index/DAX')
    tag_set = @page.parser().xpath("(//h2[.='DAX 30'])[1]/../following-sibling::div/table/tr[position()>1]")
    tag_set.each do |tr|
      td_set = tr.xpath("child::node()")
      content = td_set[0].text()
      isin = content[-12,12]
      puts "\nUsing: #{isin}"
      e = FinanzenExtractor.new(isin,' DE0008469008')
      e.extract_insider_deals(Array.new)
    end
  end
  
  task :t => :environment do
    e = FinanzenExtractor.new('DE0007037129',' DE0008469008')
    e.extract_insider_deals(Array.new)
    
  end
  
  desc "Extract the stock price target for DAX members"
  task :analyst , [:isin] => :environment do |t, args|
    e = FinanzenExtractor.new(args[:isin],' DE0008469008')
    e.extract_analysts_opinion(AnalystsOpinion.new)
  end
  
end
