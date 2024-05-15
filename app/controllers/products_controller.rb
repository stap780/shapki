class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: %i[ show edit update load_variants_images destroy]

  # GET /products or /products.json
  def index
    @search = Product.ransack(params[:q])
    @search.sorts = "id asc" if @search.sorts.empty?
    @products = @search.result(distinct: true).includes(variants: :images).paginate(page: params[:page], per_page: 100)
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
    @variants = @product.variants.order(:id)
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.turbo_stream { flash.now[:success] = t(".success") }
        format.html { redirect_to product_url(@product), notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        # format.turbo_stream { flash.now[:success] = t(".success") }
        format.html { redirect_to products_url, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_url, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
      format.turbo_stream { flash.now[:success] = t(".success") }
    end
  end

  def load_xml_data
    Product.load_xml_data
    respond_to do |format|
      flash.now[:success] = t(".success")
      format.turbo_stream do
        render turbo_stream: [
          render_turbo_flash
        ]
      end
    end
  end

  def run
    if params[:product_ids]
      params[:product_ids].each do |product_id|
        Product.find_by_id(product_id).update(status: "Process")
        ReconnectImageToVariantJob.perform_later(product_id)
      end
      respond_to do |format|
        flash.now[:success] = t(".success")
        format.turbo_stream do
          render turbo_stream: [
            render_turbo_flash
          ]
        end
      end
    else
      notice = "Выберите позиции"
      redirect_to products_url, alert: notice
    end
  end

  def load_variants
    if params[:product_ids]
      params[:product_ids].each do |product_id|
        Product.find_by_id(product_id).update(status: "Process")
        ApiLoadVariantsJob.perform_later(product_id)
      end
      respond_to do |format|
        flash.now[:success] = t(".success")
        format.turbo_stream do
          render turbo_stream: [
            # turbo_stream.update('modal',template: "shared/pending"),
            render_turbo_flash
          ]
        end
      end
    else
      notice = "Выберите позиции"
      redirect_to products_url, alert: notice
    end
  end

  def load_variants_images
    if params[:variant_ids]
      respond_to do |format|
        flash.now[:success] = t(".success")
        format.turbo_stream do
          render turbo_stream: [
            # turbo_stream.update( "buttons_variant_#{variant_id}_product_#{@product.id}", partial: 'shared/run' ),
            render_turbo_flash
          ]
        end
      end
      params[:variant_ids].each do |variant_id|
        @product.variants.find_by_id(variant_id).update(status: "Process")
        ApiImportVariantImagesJob.perform_later(@product.id, variant_id)
      end
    else
      respond_to do |format|
        flash.now[:alert] = "Выберите позиции"
        format.turbo_stream do
          render turbo_stream: [
            render_turbo_flash
          ]
        end
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(:status, :title, :uid, variants_attributes: [:id, :cariant_id, :uid, :sku, :quantity, :price, :_destroy])
    end
end
