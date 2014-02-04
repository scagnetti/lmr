require 'engine/extractor/on_vista_extractor.rb'
require 'engine/extractor/boerse_extractor.rb'
require 'engine/extractor/finanzen_extractor.rb'
require 'engine/rating_unit.rb'

# == Algorithm for evaluating the 13 rules defined by Susan Levermann.
# Thirteen figures are extracted and evaluated to determine if a certain stock is worth buying.
# Each figure is rated with -1, 0 or 1 and summed up in the end.
# * Large caps are worth buying if the result is greater than 3 
# * Small and mid caps are worth buying if the result is grater than 6
class StockProcessor
  
  # The supplied score_card is populated with the calculated figures.
  def initialize(score_card)
    LOG.info("#{self.class}: Evaluating share: #{score_card.share.name}")
    @score_card = score_card
    @extractors = Array.new
    @extractors << OnVistaExtractor.new(@score_card.share)
    @extractors << FinanzenExtractor.new(@score_card.share)
    #@extractors << BoerseExtractor.new(@score_card.share)
  end

  public
  
  # Start the evaluation
  def go
    run_on_all_extractors(@score_card.price) { |e| 
      result = e.extract_stock_price()
      @score_card.price = result['price']
      @score_card.currency = result['currency']
    }
    
    @score_card.return_on_equity = ReturnOnEquity.new
    run_on_all_extractors(@score_card.return_on_equity) { |e|
      e.extract_roe(@score_card.return_on_equity)
      RatingUnit.rate_roe(@score_card.return_on_equity)
    }
    @score_card.total_score += @score_card.return_on_equity.score
    
    @score_card.ebit_margin = EbitMargin.new
    run_on_all_extractors(@score_card.ebit_margin) { |e|
      e.extract_ebit_margin(@score_card.ebit_margin)
      RatingUnit.rate_ebit_margin(@score_card.ebit_margin)
    }
    @score_card.total_score += @score_card.ebit_margin.score
    
    @score_card.equity_ratio = EquityRatio.new
    run_on_all_extractors(@score_card.equity_ratio) { |e|
      e.extract_equity_ratio(@score_card.equity_ratio)
      RatingUnit.rate_equity_ratio(@score_card.equity_ratio)
    }
    @score_card.total_score += @score_card.equity_ratio.score
    
    @score_card.current_price_earnings_ratio = CurrentPriceEarningsRatio.new
    run_on_all_extractors(@score_card.current_price_earnings_ratio) { |e|
      e.extract_current_price_earnings_ratio(@score_card.current_price_earnings_ratio)
      RatingUnit.rate_current_price_earnings_ratio(@score_card.current_price_earnings_ratio)
    }
    @score_card.total_score += @score_card.current_price_earnings_ratio.score
    
    @score_card.average_price_earnings_ratio = AveragePriceEarningsRatio.new
    run_on_all_extractors(@score_card.average_price_earnings_ratio) { |e|
      e.extract_average_price_earnings_ratio(@score_card.average_price_earnings_ratio)
      RatingUnit.rate_average_price_earnings_ratio(@score_card.average_price_earnings_ratio)
    }
    @score_card.total_score += @score_card.average_price_earnings_ratio.score
    
    @score_card.analysts_opinion = AnalystsOpinion.new
    run_on_all_extractors(@score_card.analysts_opinion) { |e|
      e.extract_analysts_opinion(@score_card.analysts_opinion)
      RatingUnit.rate_analysts_opinion(@score_card.analysts_opinion)
    }
    @score_card.total_score += @score_card.analysts_opinion.score
    
    @score_card.reaction = Reaction.new
    run_on_all_extractors(@score_card.reaction) { |e|
      e.extract_reaction_on_figures(@score_card.reaction)
      RatingUnit.rate_reaction(@score_card.reaction)
    }
    @score_card.total_score += @score_card.reaction.score
    
    @score_card.profit_revision = ProfitRevision.new
    run_on_all_extractors(@score_card.profit_revision) { |e|
      e.extract_profit_revision(@score_card.profit_revision)
      RatingUnit.rate_profit_revision(@score_card.profit_revision)
    }
    @score_card.total_score += @score_card.profit_revision.score
    
    @score_card.stock_price_dev_half_year = StockPriceDevHalfYear.new
    # Compare with the current price of the stock
    @score_card.stock_price_dev_half_year.compare = @score_card.price
    run_on_all_extractors(@score_card.stock_price_dev_half_year) { |e|
      e.extract_stock_price_dev_half_year(@score_card.stock_price_dev_half_year)
      RatingUnit.rate_stock_price_dev_half_year(@score_card.stock_price_dev_half_year)
    }
    @score_card.total_score += @score_card.stock_price_dev_half_year.score
    
    @score_card.stock_price_dev_one_year = StockPriceDevOneYear.new
    # Compare with the current price of the stock
    @score_card.stock_price_dev_one_year.compare = @score_card.price
    run_on_all_extractors(@score_card.stock_price_dev_one_year) { |e|
      e.extract_stock_price_dev_one_year(@score_card.stock_price_dev_one_year)
      RatingUnit.rate_stock_price_dev_one_year(@score_card.stock_price_dev_one_year)
    }
    @score_card.total_score += @score_card.stock_price_dev_one_year.score
    
    @score_card.momentum = Momentum.new
    @score_card.momentum.stock_price_dev_half_year = @score_card.stock_price_dev_half_year
    @score_card.momentum.stock_price_dev_one_year = @score_card.stock_price_dev_one_year
    run_on_all_extractors(@score_card.momentum) { |e|
      RatingUnit.rate_stock_price_momentum(@score_card.momentum)
    }
    @score_card.total_score += @score_card.momentum.score
    
    @score_card.reversal = Reversal.new
    run_on_all_extractors(@score_card.reversal) { |e|
      e.extract_three_month_reversal(@score_card.reversal)
      RatingUnit.rate_reversal(@score_card.reversal)
    }
    @score_card.total_score += @score_card.reversal.score
    
    @score_card.profit_growth = ProfitGrowth.new
    run_on_all_extractors(@score_card.profit_growth) { |e|
      e.extract_profit_growth(@score_card.profit_growth)
      RatingUnit.rate_profit_growth(@score_card.profit_growth)
    }
    @score_card.total_score += @score_card.profit_growth.score
  end
  
  private

  # Try to execute the algorithm rule by rule.
  # If an extractor fails re-try with the next available extractor.
  def run_on_all_extractors(rated_figure)
    for i in 0...@extractors.size
      extractor = @extractors[i]
      begin
        # Execute the given block for each extractor
        yield extractor
        # Jump out of the loop and continue with next figure
        break
      rescue DataMiningError => e
        # Log the contained message
        LOG.warn("#{extractor.class}: #{e.to_s}")
        if i == (@extractors.size - 1)
          # Even the last extractor failed
          LOG.warn("#{self.class}: Extraction failed permanently")
          rated_figure.succeeded = false
          rated_figure.error_msg = "#{extractor.class}: #{e.to_s}"
        end
      end
    end
  end

end
