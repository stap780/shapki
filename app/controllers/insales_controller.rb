class InsalesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_insale, only: %i[ show edit update destroy ]

  # GET /insales or /insales.json
  def index
    @insales = Insale.all
  end

  # GET /insales/1 or /insales/1.json
  def show
  end

  # GET /insales/new
  def new
    if Insale.count < 1
      @insale = Insale.new
    else
      respond_to do |format|
        flash.now[:success] = "You already have integration"
        format.html { redirect_to insales_url, notice: "You already have integration" }
      end
    end
  end

  # GET /insales/1/edit
  def edit
  end

  # POST /insales or /insales.json
  def create
    @insale = Insale.new(insale_params)

    respond_to do |format|
      if @insale.save
        flash.now[:success] = t(".success")
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(Insale.new, ''),
            turbo_stream.prepend('insales', partial: 'insales/insale', locals: { insale: @insale }),
            turbo_stream.replace('add_new_button', partial: 'insales/add_new_button'),
            render_turbo_flash
          ]
        end
        format.html { redirect_to insale_url(@insale), notice: "Insale was successfully created." }
        format.json { render :show, status: :created, location: @insale }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @insale.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /insales/1 or /insales/1.json
  def update
    respond_to do |format|
      if @insale.update(insale_params)
        flash.now[:success] = t(".success")
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(@insale, partial: 'insales/insale', locals: { insale: @insale }),
            render_turbo_flash
          ]
        end
        format.html { redirect_to insale_url(@insale), notice: "Insale was successfully updated." }
        format.json { render :show, status: :ok, location: @insale }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @insale.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /insales/1 or /insales/1.json
  def destroy
    @insale.destroy!

    respond_to do |format|
      flash.now[:success] = t(".success")
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@insale),
          turbo_stream.replace('add_new_button', partial: 'insales/add_new_button'),
          render_turbo_flash
        ]
      end
      format.html { redirect_to insales_url, notice: "Insale was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_insale
      @insale = Insale.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def insale_params
      params.require(:insale).permit(:api_key, :api_password, :api_link)
    end
end
