require 'engine/stock_processor.rb'

class SharesController < ApplicationController
  # GET /shares
  # GET /shares.json
  def index
    #@shares = Share.order("name").page(params[:page]).per(25)
    @share_name = params[:share_name]
    @shares = Share.share_name(@share_name).page(params[:page]).per(20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @shares }
    end
  end

  # GET /shares/1
  # GET /shares/1.json
  def show
    @share = Share.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @share }
      format.xml { render xml: @share }
    end
  end

  # GET /shares/new
  # GET /shares/new.json
  def new
    @share = Share.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @share }
    end
  end

  # GET /shares/1/edit
  def edit
    @share = Share.find(params[:id])
  end

  # POST /shares
  # POST /shares.json
  def create
    share_params = params[:share]
    @share = Share.new(share_params)
    @share.stock_index = StockIndex.find(share_params[:stock_index_id])

    respond_to do |format|
      if @share.save
        format.html { redirect_to @share, notice: 'Share was successfully created.' }
        format.json { render json: @share, status: :created, location: @share }
      else
        format.html { render action: "new" }
        format.json { render json: @share.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /shares/1
  # PUT /shares/1.json
  def update
    @share = Share.find(params[:id])

    respond_to do |format|
      if @share.update_attributes(params[:share])
        format.html { redirect_to @share, notice: 'Share was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @share.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shares/1
  # DELETE /shares/1.json
  def destroy
    @share = Share.find(params[:id])
    @share.destroy

    respond_to do |format|
      format.html { redirect_to shares_url }
      format.json { head :no_content }
    end
  end

  def lookup_insider_trades
    @share = Share.find(params[:id])
    results = Array.new
    e = FinanzenExtractor.new(@share)
    e.extract_insider_deals(results)
    redirect_to "/insider_deals?share_id=#{@share.id}", notice: 'Looked up insider deals successfully.'
  end
end
