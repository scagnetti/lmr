class StockIndicesController < ApplicationController
  # GET /indices
  # GET /indices.json
  def index
    @stock_indices = StockIndex.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @stock_indices }
    end
  end

  # GET /indices/1
  # GET /indices/1.json
  def show
    @stock_index = StockIndex.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @stock_index }
    end
  end

  # GET /indices/new
  # GET /indices/new.json
  def new
    @stock_index = StockIndex.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @stock_index }
    end
  end

  # GET /indices/1/edit
  def edit
    @stock_index = StockIndex.find(params[:id])
  end

  # POST /indices
  # POST /indices.json
  def create
    @stock_index = StockIndex.new(params[:stock_index])

    respond_to do |format|
      if @stock_index.save
        format.html { redirect_to @stock_index, notice: 'Index was successfully created.' }
        format.json { render json: @stock_index, status: :created, location: @stock_index }
      else
        format.html { render action: "new" }
        format.json { render json: @stock_index.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /indices/1
  # PUT /indices/1.json
  def update
    @stock_index = StockIndex.find(params[:id])

    respond_to do |format|
      if @stock_index.update_attributes(params[:index])
        format.html { redirect_to @stock_index, notice: 'Index was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @stock_index.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /indices/1
  # DELETE /indices/1.json
  def destroy
    @stock_index = StockIndex.find(params[:id])
    @stock_index.destroy

    respond_to do |format|
      format.html { redirect_to indices_url }
      format.json { head :no_content }
    end
  end
end
