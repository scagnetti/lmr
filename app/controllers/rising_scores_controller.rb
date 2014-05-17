class RisingScoresController < ApplicationController
  # GET /rising_scores
  # GET /rising_scores.json
  def index
    @rising_scores = RisingScore.joins('INNER JOIN shares ON shares.isin = rising_scores.isin').where("rising_scores.created_at >= ?", Time.zone.now.beginning_of_day).order("rising_scores.days DESC").page(params[:page]).per(20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rising_scores }
    end
  end

  # GET /rising_scores/1
  # GET /rising_scores/1.json
  def show
    @rising_score = RisingScore.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @rising_score }
    end
  end

  # GET /rising_scores/new
  # GET /rising_scores/new.json
  def new
    @rising_score = RisingScore.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rising_score }
    end
  end

  # GET /rising_scores/1/edit
  def edit
    @rising_score = RisingScore.find(params[:id])
  end

  # POST /rising_scores
  # POST /rising_scores.json
  def create
    @rising_score = RisingScore.new(params[:rising_score])

    respond_to do |format|
      if @rising_score.save
        format.html { redirect_to @rising_score, notice: 'Rising score was successfully created.' }
        format.json { render json: @rising_score, status: :created, location: @rising_score }
      else
        format.html { render action: "new" }
        format.json { render json: @rising_score.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rising_scores/1
  # PUT /rising_scores/1.json
  def update
    @rising_score = RisingScore.find(params[:id])

    respond_to do |format|
      if @rising_score.update_attributes(params[:rising_score])
        format.html { redirect_to @rising_score, notice: 'Rising score was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @rising_score.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rising_scores/1
  # DELETE /rising_scores/1.json
  def destroy
    @rising_score = RisingScore.find(params[:id])
    @rising_score.destroy

    respond_to do |format|
      format.html { redirect_to rising_scores_url }
      format.json { head :no_content }
    end
  end
end
