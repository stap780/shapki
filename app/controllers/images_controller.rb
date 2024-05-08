class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product
  before_action :set_variant
  before_action :set_image, only: %i[ show edit update destroy ]
  include ActionView::RecordIdentifier

  # GET /images or /images.json
  def index
    # @images = Image.all
    @images = @variant.images
  end

  # GET /images/1 or /images/1.json
  def show
  end

  # GET /images/new
  def new
    # @image = Image.new
    @image = @variant.images.build
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images or /images.json
  def create
    # @image = Image.new(image_params)
    @image = @variant.images.build(image_params)
    respond_to do |format|
      if @image.save
        format.html { redirect_to image_url(@image), notice: "Image was successfully created." }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /images/1 or /images/1.json
  def update
    respond_to do |format|
      if @image.update(image_params)
        format.html { redirect_to image_url(@image), notice: "Image was successfully updated." }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # if variant present use this upload
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

    # This use when we save to S3
    file = upload_blob.open do |tempfile|
      puts "upload_blob ======= upload_blob"
      puts "tempfile.path"
      puts tempfile.path
      ImageProcessing::MiniMagick.source(tempfile.path).saver!(quality: 90)
    end

    new_blob = ActiveStorage::Blob.create_and_upload!(io: file, filename: filename)

    @blob = new_blob

    respond_to do |format|
      flash.now[:success] = t(".success")
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.append(dom_id(@product, dom_id(@variant, :images)), partial: "images/image", locals: { blob: @blob, image_id: nil, image_position: @blob.id, variant_id: @variant.id, f: nil }),
          render_turbo_flash
        ]
      end

    end
  end

  # # use only for flash message because delete images from product happend while update form
  # def delete
  #   # Fetch the blob using the signed id
  #   @blob_signed_id = params[:blob_signed_id]
  #   image = params[:image_id].present? ? Image.find(params[:image_id]) : nil
  #   blob = ActiveStorage::Blob.find_signed(@blob_signed_id)

  #   if image.present?
  #     image.destroy
  #   else
  #     blob.purge
  #   end

  #   respond_to do |format|
  #     format.turbo_stream { flash.now[:notice] = t(".success") }
  #   end
  # end

  # DELETE /images/1 or /images/1.json
  def destroy
    @image.destroy!

    respond_to do |format|
      format.html { redirect_to images_url, notice: "Image was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_variant
    @variant = @product.variants.find(params[:variant_id])
  end

    # Use callbacks to share common setup or constraints between actions.
    def set_image
      #@image = Image.find(params[:id])
      @image = @variant.images.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def image_params
      params.require(:image).permit(:uid, :title, :position, :variant_id)
    end
end
