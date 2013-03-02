require 'engine/stock_processor.rb'

class ScoreCardsController < ApplicationController
  # GET /score_cards
  # GET /score_cards.json
  def index
    if params[:d] == nil
      @score_cards = ScoreCard.order("total_score DESC").page(params[:page]).per(20)
    else
      d = params[:d].to_date
      range = d.midnight..(d.midnight + 1.day)
      @score_cards = ScoreCard.where(:created_at => range).order("total_score DESC").page(params[:page]).per(20)
    end

    respond_to do |format|
      format.html # index.html.erb
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

  # GET /score_cards/new
  # GET /score_cards/new.json
  def new
    @score_card = ScoreCard.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @score_card }
    end
  end

  # GET /score_cards/1/edit
  def edit
    @score_card = ScoreCard.find(params[:id])
  end

  # POST /score_cards
  # POST /score_cards.json
  def create
    @score_card = ScoreCard.new(params[:score_card])
    @score_card.stock_index = StockIndex.find(params[:stock_index])
    
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

  # PUT /score_cards/1
  # PUT /score_cards/1.json
  def update
    @score_card = ScoreCard.find(params[:id])

    respond_to do |format|
      if @score_card.update_attributes(params[:score_card])
        format.html { redirect_to @score_card, notice: 'Score card was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @score_card.errors, status: :unprocessable_entity }
      end
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
end
