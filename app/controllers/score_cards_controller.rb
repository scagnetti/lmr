require 'engine/stock_processor.rb'

class ScoreCardsController < ApplicationController
  # GET /score_cards
  # GET /score_cards.json
  def index
    @share_name = params[:share_name]
    @created = params[:d]
    @score_cards = ScoreCard.creation(@created).share_name(@share_name).page(params[:page]).per(20)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render xml: @score_cards }
      format.json { render json: @score_cards }
    end
  end

  # GET /score_cards/1
  # GET /score_cards/1.json
  def show
    @score_card = ScoreCard.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @score_card }
    end
  end

  # DELETE /score_cards/1
  # DELETE /score_cards/1.json
  def destroy
    @score_card = ScoreCard.find(params[:id])
    @score_card.destroy

    respond_to do |format|
      format.html { redirect_to score_cards_url }
      format.json { head :no_content }
    end
  end

  def assess_share
    share = Share.where(:isin => params[:isin]).first
    @score_card = ScoreCard.new()
    @score_card.share = share
    # Run the algorithm
    stock_processor = StockProcessor.new(@score_card)
    stock_processor.go()
    
    respond_to do |format|
      if @score_card.save
        format.html { redirect_to @score_card, notice: 'Score card was successfully created.' }
        format.json { render json: @score_card, status: :created, location: @score_card }
      else
        format.html { render action: "new" }
        format.json { render json: @score_card.errors, status: :unprocessable_entity }
      end
    end
  end
end
