class DepositEntriesController < ApplicationController
  before_action :set_deposit_entry, only: [:show, :edit, :update, :destroy]

  # GET /deposit_entries
  def index
    @deposit_entries = DepositEntry.all.order(:archived, :balance)
  end

  # GET /deposit_entries/1
  def show
  end

  # GET /deposit_entries/new
  def new
    @deposit_entry = DepositEntry.new
  end

  # GET /deposit_entries/1/edit
  def edit
  end

  # POST /deposit_entries
  def create
    @deposit_entry = DepositEntry.new(deposit_entry_params)

    if @deposit_entry.save
      redirect_to @deposit_entry, notice: 'Deposit entry was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /deposit_entries/1
  def update
    if @deposit_entry.update(deposit_entry_params)
      redirect_to @deposit_entry, notice: 'Deposit entry was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /deposit_entries/1
  def destroy
    @deposit_entry.destroy
    redirect_to deposit_entries_url, notice: 'Deposit entry was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_deposit_entry
      @deposit_entry = DepositEntry.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def deposit_entry_params
      params.require(:deposit_entry).permit(:balance)
    end
end
