class PersonOfInterestsController < ApplicationController
  # GET /person_of_interests
  # GET /person_of_interests.json
  def index
    @person_of_interests = PersonOfInterest.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @person_of_interests }
    end
  end

  # GET /person_of_interests/1
  # GET /person_of_interests/1.json
  def show
    @person_of_interest = PersonOfInterest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @person_of_interest }
    end
  end

  # GET /person_of_interests/new
  # GET /person_of_interests/new.json
  def new
    @person_of_interest = PersonOfInterest.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @person_of_interest }
    end
  end

  # GET /person_of_interests/1/edit
  def edit
    @person_of_interest = PersonOfInterest.find(params[:id])
  end

  # POST /person_of_interests
  # POST /person_of_interests.json
  def create
    @person_of_interest = PersonOfInterest.new(person_of_interest_params)

    respond_to do |format|
      if @person_of_interest.save
        format.html { redirect_to @person_of_interest, notice: 'Person of interest was successfully created.' }
        format.json { render json: @person_of_interest, status: :created, location: @person_of_interest }
      else
        format.html { render action: "new" }
        format.json { render json: @person_of_interest.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /person_of_interests/1
  # PUT /person_of_interests/1.json
  def update
    @person_of_interest = PersonOfInterest.find(params[:id])

    respond_to do |format|
      if @person_of_interest.update_attributes(person_of_interest_params)
        format.html { redirect_to @person_of_interest, notice: 'Person of interest was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @person_of_interest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /person_of_interests/1
  # DELETE /person_of_interests/1.json
  def destroy
    @person_of_interest = PersonOfInterest.find(params[:id])
    @person_of_interest.destroy

    respond_to do |format|
      format.html { redirect_to person_of_interests_url }
      format.json { head :no_content }
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def person_of_interest_params
    params.require(:person_of_interest).permit(:desc, :first_name, :last_name)
  end
end
