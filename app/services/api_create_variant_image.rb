class ApiCreateVariantImage < ApplicationService

    def initialize(product_uid, variant_uid, images)
        Insale.api_init
        @ins_pr_id = product_uid
        @ins_var_id = variant_uid
        @ins_variant = InsalesApi::Variant.find( variant_uid, params: {product_id:  product_uid} )
        @error_message = nil
        @images = images
        @ins_image_ids = []
    end
  
    def call
      puts "ApiCreateVariantImage call"
      if @images.size > 0
        api_clear_variant_image_ids
        add_image_to_insales_product
        set_variants_images
        delete_unattached_blobs
      end
    end
  
    private

    def api_clear_variant_image_ids #this is for position
      image_ids = @ins_variant.image_ids
      image_ids.each do |image_id|
        ins_im = InsalesApi::Image.find(image_id, params: {product_id: @ins_pr_id})
        ins_im.destroy
      end
    end

    def add_image_to_insales_product
      @images.each do |image|
        #im = InsalesApi::Image.new(src: image.s3_url, product_id: @ins_pr_id)
        im = InsalesApi::Image.new( attachment: Base64.encode64(image.file.download), filename: image.file.filename.to_s, title: image.title, product_id: @ins_pr_id)
        im.save
        @ins_image_ids << im.id
        image.update(uid: im.id)
      end
    end

    def set_variants_images
      @ins_variant.image_ids = @ins_image_ids
      @ins_variant.save
    end

    def delete_unattached_blobs
      ActiveStorage::Blob.unattached.each(&:purge_later)
      # ActiveStorage::Blob.unattached.each(&:purge)
    end

end