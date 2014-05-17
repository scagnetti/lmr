class InsiderDealsController < ApplicationController
  # GET /insider_deals
  # GET /insider_deals.json
  def index
    @insider_deals = InsiderDeal.order(occurred: :desc).page(params[:page]).per(20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @insider_deals }
    end
  end

  # GET /insider_deals/1
  # GET /insider_deals/1.json
  def show
    @insider_deal = InsiderDeal.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @insider_deal }
    end
  end

  # GET /insider_deals/new
  # GET /insider_deals/new.json
  def new
    @insider_deal = InsiderDeal.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @insider_deal }
    end
  end

  # GET /insider_deals/1/edit
  def edit
    @insider_deal = InsiderDeal.find(params[:id])
  end

  # POST /insider_deals
  # POST /insider_deals.json
  def create
    @insider_deal = InsiderDeal.new(params[:insider_deal])

    respond_to do |format|
      if @insider_deal.save
        format.html { redirect_to @insider_deal, notice: 'Insider deal was successfully created.' }
        format.json { render json: @insider_deal, status: :created, location: @insider_deal }
      else
        format.html { render action: "new" }
        format.json { render json: @insider_deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /insider_deals/1
  # PUT /insider_deals/1.json
  def update
    @insider_deal = InsiderDeal.find(params[:id])

    respond_to do |format|
      if @insider_deal.update_attributes(params[:insider_deal])
        format.html { redirect_to @insider_deal, notice: 'Insider deal was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @insider_deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /insider_deals/1
  # DELETE /insider_deals/1.json
  def destroy
    @insider_deal = InsiderDeal.find(params[:id])
    @insider_deal.destroy

    respond_to do |format|
      format.html { redirect_to insider_deals_url }
      format.json { head :no_content }
    end
  end
end
