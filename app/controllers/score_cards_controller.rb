require 'engine/stock_processor.rb'

class ScoreCardsController < ApplicationController
  # GET /score_cards
  # GET /score_cards.json
  def index
    @stock_indices = StockIndex.all
    @share_name = params[:share_name]
    @stock_index_id = params[:stock_index_id]
    @score_cards = ScoreCard.latest_only.share_name(@share_name).stock_index(@stock_index_id).order("total_score DESC").page(params[:page]).per(20)
    
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

  def new
    @score_card = ScoreCard.new

    respond_to do |format|
      format.html # new.html.erb
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

  def create
    index_id = params[:scope]
    if index_id == -1
      shares = Share.where(active: true)
    else
      shares = Share.joins(:stock_index).where(active: true, stock_indices: {id: index_id})
    end
    shares.each do |s|
      begin
        score_card = ScoreCard.new()
        score_card.share = s
        stock_processor = StockProcessor.new(score_card)
        stock_processor.run_extraction()
        stock_processor.run_rating()
        score_card.save!
      rescue StandardError => se
        puts "#{s.name} - FAILED because: #{se.message}"
        failed << s
      end
    end

    respond_to do |format|
      format.html { redirect_to score_cards_path, notice: 'Score Cards where successfully created.' }
    end
  end

  def assess_share
    share = Share.where(:isin => params[:isin]).first
    @score_card = ScoreCard.create(:share => share)

    stock_processor = StockProcessor.new(@score_card)
    stock_processor.run_extraction()
    stock_processor.run_rating()
    
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
