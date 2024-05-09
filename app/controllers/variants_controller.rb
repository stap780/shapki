class VariantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product
  before_action :set_variant, only: %i[ show edit update load_images destroy ]
  include ActionView::RecordIdentifier

  # GET /variants or /variants.json
  def index
    #@variants = Variant.all
    @variants = @product.variants.order(:id)
  end

  # GET /variants/1 or /variants/1.json
  def show
  end

  # GET /variants/new
  def new
    # @variant = Variant.new
    @variant = @product.variants.build
    # @image = @variant.images.build
  end

  # GET /variants/1/edit
  def edit
  end

  # POST /variants or /variants.json
  def create
    @variant = @product.variants.build(variant_params)

    respond_to do |format|
      if @variant.save
        flash.now[:success] = t(".success")
        format.turbo_stream do
          render turbo_stream: [
            render_turbo_flash
          ]
        end
        format.html { redirect_to variant_url(@variant), notice: "Variant was successfully created." }
        format.json { render :show, status: :created, location: @variant }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @variant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /variants/1 or /variants/1.json
  def update
    respond_to do |format|
      if @variant.update(variant_params)
        flash.now[:success] = t(".success")
        format.turbo_stream do
          render turbo_stream: [
            render_turbo_flash
          ]
        end
        format.html { redirect_to variant_url(@variant), notice: "Variant was successfully updated." }
        format.json { render :show, status: :ok, location: @variant }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @variant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /variants/1 or /variants/1.json
  def destroy
    @variant.destroy!

    respond_to do |format|
      flash.now[:success] = t(".success")
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(dom_id(@product, dom_id(@variant))),
          render_turbo_flash
        ]
      end
      format.html { redirect_to variants_url, notice: "Variant was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # if variant new use this upload
  def upload
    params.require(:blob_signed_id)
    signed_id = params["blob_signed_id"]
    upload_blob = ActiveStorage::Blob.find_signed(signed_id)
    filename = upload_blob.filename
    content_type = upload_blob.content_type

    # This is use when we save image to Disk storage
    # upload_image_path = ActiveStorage::Blob.service.send(:path_for, upload_blob.key)
    # magick_image_path = ImageProcessing::MiniMagick.source(upload_image_path).saver!(quality: 78)
    # new_blob = ActiveStorage::Blob.create_and_upload!(  io: magick_image_path,
    #                                                     filename: filename,
    #                                                     content_type: content_type )

    # This use when we save to S3 and need process image file (for examle change quality)
    file = upload_blob.open do |tempfile|
      puts "upload_blob ======= upload_blob"
      puts "tempfile.path"
      puts tempfile.path
      ImageProcessing::Vips.source(tempfile.path).saver!(quality: 90)
    end

    new_blob = ActiveStorage::Blob.create_and_upload!(io: file, filename: filename)

    @blob = new_blob

    variant = @product.variants.build
    
    respond_to do |format|
      flash.now[:success] = t(".success")
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.append(dom_id(@product, dom_id(variant, :images)), partial: "images/image", locals: { blob: @blob, image_id: nil, image_position: @blob.id, variant_id: @variant_id, f: nil }),
          render_turbo_flash
        ]
      end

    end
  end

  # use only for flash message because delete images from product happend while update form
  def delete_image
    # Fetch the blob using the signed id
    @blob_signed_id = params[:blob_signed_id]
    image = params[:image_id].present? ? Image.find(params[:image_id]) : nil
    blob = ActiveStorage::Blob.find_signed(@blob_signed_id)

    if image.present?
      if image.uid.present?
        Insale.api_init
        begin
          ins_im = InsalesApi::Image.find(image.uid, params: {product_id: @product.uid})
        rescue ActiveResource::ResourceNotFound
          puts "api image not present"
        else
          ins_im.destroy
        end
      end
      image.destroy
    else
      blob.purge
    end

    respond_to do |format|
      flash.now[:success] = t(".success")
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove( @blob_signed_id ),
          render_turbo_flash
        ]
      end
    end
  end

  # switch off because we use position input inside form and save position with form save
  def sort_image
    # puts "sort_image params => "+params.to_s
    # @image = @product.images.find_by_id(params[:sort_item_id])
    # @image.insert_at params[:new_position]
    head :ok
  end

  def load_images
    if params[:variant_ids]
      params[:variant_ids].each do |variant_id|
        # @product.variants.find_by_id(variant_id).update!(status: "Process")
        ApiImportVariantImagesJob.perform_later(@product.id, variant_id)
        respond_to do |format|
          flash.now[:success] = t(".success")
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.update( "buttons_variant_#{variant_id}_product_#{@product.id}", partial: 'shared/run' ),
              render_turbo_flash
            ]
          end
        end
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

  def run
    if params[:variant_ids]
      params[:variant_ids].each do |variant_id|
        # @product.variants.find_by_id(variant_id).update(status: "Process")
        ApiCreateVariantImageJob.perform_later(@product.id, variant_id)
        respond_to do |format|
          flash.now[:success] = t(".success")
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.update( "buttons_variant_#{variant_id}_product_#{@product.id}", partial: 'shared/run' ),
              render_turbo_flash
            ]
          end
        end
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

    def set_product
      @product = Product.find(params[:product_id])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_variant
      #@variant = Variant.find(params[:id])
      @variant = @product.variants.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def variant_params
      params.require(:variant).permit(:status, :uid, :sku, :quantity, :price, :product_id, :barcode, images_attributes: [:id, :uid, :variant_id, :title, :position, :file, :_destroy])
    end
end
