class ImportsController < ApplicationController
  before_action :set_import, only: %i[ show edit update run destroy ]

  # GET /imports or /imports.json
  def index
    # @imports = Import.all
    @search = Import.ransack(params[:q])
    @search.sorts = "id asc" if @search.sorts.empty?
    @imports = @search.result(distinct: true).paginate(page: params[:page], per_page: 100)
  end

  # GET /imports/1 or /imports/1.json
  def show
  end

  # GET /imports/new
  def new
    @import = Import.new
  end

  # GET /imports/1/edit
  def edit
  end

  # POST /imports or /imports.json
  def create
    @import = Import.new(import_params)

    respond_to do |format|
      if @import.save
        format.html { redirect_to import_url(@import), notice: "Import was successfully created." }
        format.json { render :show, status: :created, location: @import }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @import.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /imports/1 or /imports/1.json
  def update
    respond_to do |format|
      if @import.update(import_params)
        format.html { redirect_to import_url(@import), notice: "Import was successfully updated." }
        format.json { render :show, status: :ok, location: @import }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @import.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /imports/1 or /imports/1.json
  def destroy
    @import.destroy!

    respond_to do |format|
      format.html { redirect_to imports_url, notice: "Import was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def run
    ImportConnectImageJob.perform_later(@import.id)
    respond_to do |format|
      flash.now[:success] = t(".success")
      format.turbo_stream do
        render turbo_stream: [
          render_turbo_flash
        ]
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_import
      @import = Import.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def import_params
      params.require(:import).permit(:title, :link)
    end
end
