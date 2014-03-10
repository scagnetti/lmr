require 'engine/extractor/on_vista_extractor.rb'
require 'engine/extractor/boerse_extractor.rb'
require 'engine/extractor/finanzen_extractor.rb'
require 'engine/rating/rating_service.rb'

# Algorithm for evaluating the 13 rules defined by Susan Levermann.
# Thirteen figures are extracted and evaluated to determine if a certain stock is worth buying.
# Each figure is rated with -1, 0 or 1 and summed up in the end.
# * Large caps are worth buying if the result is greater than 3 
# * Small and mid caps are worth buying if the result is grater than 6
class StockProcessor
  
  # The supplied score_card is populated with the calculated figures.
  def initialize(score_card)
    LOG.info("#{self.class}: Starting configuration process for share: #{score_card.share.name}")
    @score_card = score_card
    @score_card.return_on_equity = ReturnOnEquity.new
    @score_card.ebit_margin = EbitMargin.new
    @score_card.equity_ratio = EquityRatio.new
    @score_card.current_price_earnings_ratio = CurrentPriceEarningsRatio.new
    @score_card.average_price_earnings_ratio = AveragePriceEarningsRatio.new
    @score_card.analysts_opinion = AnalystsOpinion.new
    @score_card.reaction = Reaction.new
    @score_card.profit_revision = ProfitRevision.new
    @score_card.stock_price_dev_half_year = StockPriceDevHalfYear.new
    @score_card.stock_price_dev_one_year = StockPriceDevOneYear.new
    @score_card.momentum = Momentum.new
    @score_card.reversal = Reversal.new
    @score_card.profit_growth = ProfitGrowth.new
    @extractors = Array.new
    LOG.info("#{self.class}: Initializing extractor: OnVistaExtractor")
    @extractors << OnVistaExtractor.new(@score_card.share)
    LOG.info("#{self.class}: Initialization of extractor: OnVistaExtractor completed")
    LOG.info("#{self.class}: Initializing extractor: FinanzenExtractor")
    @extractors << FinanzenExtractor.new(@score_card.share)
    LOG.info("#{self.class}: Initialization of extractor: FinanzenExtractor completed")
    #@extractors << BoerseExtractor.new(@score_card.share)
    rating_service = RatingService.new
    @rating_unit = rating_service.choose_rating_unit(@score_card.share.size, @score_card.share.financial)
    LOG.info("#{self.class}: Using #{@rating_unit.class}")
    LOG.info("#{self.class}: Configuration process for share: #{@score_card.share.name} completed")
  end

  public
  
  # Extract the figures described by Susan Levermann
  def run_extraction
    LOG.info("#{self.class}: Starting extraction process for share: #{@score_card.share.name}")
    run_on_all_extractors(@score_card.price) { |e| 
      result = e.extract_stock_price()
      @score_card.price = result['price']
      @score_card.currency = result['currency']
    }
    
    run_on_all_extractors(@score_card.return_on_equity) { |e|
      e.extract_roe(@score_card.return_on_equity)
    }

    run_on_all_extractors(@score_card.ebit_margin) { |e|
      e.extract_ebit_margin(@score_card.ebit_margin)
    }
    
    run_on_all_extractors(@score_card.equity_ratio) { |e|
      e.extract_equity_ratio(@score_card.equity_ratio)
    }

    run_on_all_extractors(@score_card.current_price_earnings_ratio) { |e|
      e.extract_current_price_earnings_ratio(@score_card.current_price_earnings_ratio)
    }

    run_on_all_extractors(@score_card.average_price_earnings_ratio) { |e|
      e.extract_average_price_earnings_ratio(@score_card.average_price_earnings_ratio)
    }

    run_on_all_extractors(@score_card.analysts_opinion) { |e|
      e.extract_analysts_opinion(@score_card.analysts_opinion)
    }

    run_on_all_extractors(@score_card.reaction) { |e|
      e.extract_reaction_on_figures(@score_card.reaction)
    }

    run_on_all_extractors(@score_card.profit_revision) { |e|
      e.extract_profit_revision(@score_card.profit_revision)
    }

    run_on_all_extractors(@score_card.stock_price_dev_half_year) { |e|
      e.extract_stock_price_dev_half_year(@score_card.stock_price_dev_half_year)
    }
    
    run_on_all_extractors(@score_card.stock_price_dev_one_year) { |e|
      e.extract_stock_price_dev_one_year(@score_card.stock_price_dev_one_year)
    }

    run_on_all_extractors(@score_card.reversal) { |e|
      e.extract_three_month_reversal(@score_card.reversal)
    }

    run_on_all_extractors(@score_card.profit_growth) { |e|
      e.extract_profit_growth(@score_card.profit_growth)
    }
    LOG.info("#{self.class}: Extraction process for share: #{@score_card.share.name} completed")
  end
  
  # Applies the rating rules on the extracted figures
  def run_rating
    LOG.info("#{self.class}: Starting rating process for share: #{@score_card.share.name}")
    @rating_unit.rate_roe(@score_card.return_on_equity) if @score_card.return_on_equity.succeeded
    @rating_unit.rate_ebit_margin(@score_card.ebit_margin) if @score_card.ebit_margin.succeeded
    @rating_unit.rate_equity_ratio(@score_card.equity_ratio) if @score_card.equity_ratio.succeeded
    @rating_unit.rate_current_price_earnings_ratio(@score_card.current_price_earnings_ratio) if @score_card.current_price_earnings_ratio.succeeded
    @rating_unit.rate_average_price_earnings_ratio(@score_card.average_price_earnings_ratio) if @score_card.average_price_earnings_ratio.succeeded
    @rating_unit.rate_analysts_opinion(@score_card.analysts_opinion) if @score_card.analysts_opinion.succeeded
    @rating_unit.rate_reaction(@score_card.reaction) if @score_card.reaction.succeeded
    @rating_unit.rate_profit_revision(@score_card.profit_revision) if @score_card.profit_revision.succeeded
    # Note: Compare the extracted price with the current price of the stock
    @score_card.stock_price_dev_half_year.compare = @score_card.price
    @rating_unit.rate_stock_price_dev_half_year(@score_card.stock_price_dev_half_year) if @score_card.stock_price_dev_half_year.succeeded
    # Note: Compare the extracted price with the current price of the stock
    @score_card.stock_price_dev_one_year.compare = @score_card.price
    @rating_unit.rate_stock_price_dev_one_year(@score_card.stock_price_dev_one_year) if @score_card.stock_price_dev_one_year.succeeded
    # Note: We need to know the stock price development for past half and complete year
    @score_card.momentum.stock_price_dev_half_year = @score_card.stock_price_dev_half_year
    @score_card.momentum.stock_price_dev_one_year = @score_card.stock_price_dev_one_year
    @rating_unit.rate_stock_price_momentum(@score_card.momentum) if @score_card.momentum.succeeded
    @rating_unit.rate_reversal(@score_card.reversal) if @score_card.reversal.succeeded
    @rating_unit.rate_profit_growth(@score_card.profit_growth) if @score_card.profit_growth.succeeded
    
    # Sum up the single scores to the total score
    @score_card.total_score += @score_card.return_on_equity.score
    @score_card.total_score += @score_card.ebit_margin.score
    @score_card.total_score += @score_card.equity_ratio.score
    @score_card.total_score += @score_card.current_price_earnings_ratio.score
    @score_card.total_score += @score_card.average_price_earnings_ratio.score
    @score_card.total_score += @score_card.analysts_opinion.score
    @score_card.total_score += @score_card.reaction.score
    @score_card.total_score += @score_card.profit_revision.score
    @score_card.total_score += @score_card.stock_price_dev_half_year.score
    @score_card.total_score += @score_card.stock_price_dev_one_year.score
    @score_card.total_score += @score_card.momentum.score
    @score_card.total_score += @score_card.reversal.score
    @score_card.total_score += @score_card.profit_growth.score
    LOG.info("#{self.class}: Rating process for share: #{@score_card.share.name} completed")
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
  
  # Start the evaluation
  # def go
    # run_on_all_extractors(@score_card.price) { |e| 
      # result = e.extract_stock_price()
      # @score_card.price = result['price']
      # @score_card.currency = result['currency']
    # }
#     
    # @score_card.return_on_equity = ReturnOnEquity.new
    # run_on_all_extractors(@score_card.return_on_equity) { |e|
      # e.extract_roe(@score_card.return_on_equity)
      # @rating_unit.rate_roe(@score_card.return_on_equity)
    # }
    # @score_card.total_score += @score_card.return_on_equity.score
#     
    # @score_card.ebit_margin = EbitMargin.new
    # run_on_all_extractors(@score_card.ebit_margin) { |e|
      # e.extract_ebit_margin(@score_card.ebit_margin)
      # @rating_unit.rate_ebit_margin(@score_card.ebit_margin)
    # }
    # @score_card.total_score += @score_card.ebit_margin.score
#     
    # @score_card.equity_ratio = EquityRatio.new
    # run_on_all_extractors(@score_card.equity_ratio) { |e|
      # e.extract_equity_ratio(@score_card.equity_ratio)
      # @rating_unit.rate_equity_ratio(@score_card.equity_ratio)
    # }
    # @score_card.total_score += @score_card.equity_ratio.score
#     
    # @score_card.current_price_earnings_ratio = CurrentPriceEarningsRatio.new
    # run_on_all_extractors(@score_card.current_price_earnings_ratio) { |e|
      # e.extract_current_price_earnings_ratio(@score_card.current_price_earnings_ratio)
      # @rating_unit.rate_current_price_earnings_ratio(@score_card.current_price_earnings_ratio)
    # }
    # @score_card.total_score += @score_card.current_price_earnings_ratio.score
#     
    # @score_card.average_price_earnings_ratio = AveragePriceEarningsRatio.new
    # run_on_all_extractors(@score_card.average_price_earnings_ratio) { |e|
      # e.extract_average_price_earnings_ratio(@score_card.average_price_earnings_ratio)
      # @rating_unit.rate_average_price_earnings_ratio(@score_card.average_price_earnings_ratio)
    # }
    # @score_card.total_score += @score_card.average_price_earnings_ratio.score
#     
    # @score_card.analysts_opinion = AnalystsOpinion.new
    # run_on_all_extractors(@score_card.analysts_opinion) { |e|
      # e.extract_analysts_opinion(@score_card.analysts_opinion)
      # @rating_unit.rate_analysts_opinion(@score_card.analysts_opinion)
    # }
    # @score_card.total_score += @score_card.analysts_opinion.score
#     
    # @score_card.reaction = Reaction.new
    # run_on_all_extractors(@score_card.reaction) { |e|
      # e.extract_reaction_on_figures(@score_card.reaction)
      # @rating_unit.rate_reaction(@score_card.reaction)
    # }
    # @score_card.total_score += @score_card.reaction.score
#     
    # @score_card.profit_revision = ProfitRevision.new
    # run_on_all_extractors(@score_card.profit_revision) { |e|
      # e.extract_profit_revision(@score_card.profit_revision)
      # @rating_unit.rate_profit_revision(@score_card.profit_revision)
    # }
    # @score_card.total_score += @score_card.profit_revision.score
#     
    # @score_card.stock_price_dev_half_year = StockPriceDevHalfYear.new
    # # Compare with the current price of the stock
    # @score_card.stock_price_dev_half_year.compare = @score_card.price
    # run_on_all_extractors(@score_card.stock_price_dev_half_year) { |e|
      # e.extract_stock_price_dev_half_year(@score_card.stock_price_dev_half_year)
      # @rating_unit.rate_stock_price_dev_half_year(@score_card.stock_price_dev_half_year)
    # }
    # @score_card.total_score += @score_card.stock_price_dev_half_year.score
#     
    # @score_card.stock_price_dev_one_year = StockPriceDevOneYear.new
    # # Compare with the current price of the stock
    # @score_card.stock_price_dev_one_year.compare = @score_card.price
    # run_on_all_extractors(@score_card.stock_price_dev_one_year) { |e|
      # e.extract_stock_price_dev_one_year(@score_card.stock_price_dev_one_year)
      # @rating_unit.rate_stock_price_dev_one_year(@score_card.stock_price_dev_one_year)
    # }
    # @score_card.total_score += @score_card.stock_price_dev_one_year.score
#     
    # @score_card.momentum = Momentum.new
    # @score_card.momentum.stock_price_dev_half_year = @score_card.stock_price_dev_half_year
    # @score_card.momentum.stock_price_dev_one_year = @score_card.stock_price_dev_one_year
    # run_on_all_extractors(@score_card.momentum) { |e|
      # @rating_unit.rate_stock_price_momentum(@score_card.momentum)
    # }
    # @score_card.total_score += @score_card.momentum.score
#     
    # @score_card.reversal = Reversal.new
    # run_on_all_extractors(@score_card.reversal) { |e|
      # e.extract_three_month_reversal(@score_card.reversal)
      # @rating_unit.rate_reversal(@score_card.reversal)
    # }
    # @score_card.total_score += @score_card.reversal.score
#     
    # @score_card.profit_growth = ProfitGrowth.new
    # run_on_all_extractors(@score_card.profit_growth) { |e|
      # e.extract_profit_growth(@score_card.profit_growth)
      # @rating_unit.rate_profit_growth(@score_card.profit_growth)
    # }
    # @score_card.total_score += @score_card.profit_growth.score
  # end
#   

end
