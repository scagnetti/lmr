class RisingScoresController < ApplicationController
  # GET /rising_scores
  # GET /rising_scores.json
  def index
    @rising_scores = RisingScore.joins('INNER JOIN shares ON shares.isin = rising_scores.isin').where("rising_scores.created_at >= ?", (Time.zone.now - 1.day).beginning_of_day).order("rising_scores.days DESC").page(params[:page]).per(20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rising_scores }
    end
  end

end
