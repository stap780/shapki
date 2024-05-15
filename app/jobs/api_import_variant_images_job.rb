class ApiImportVariantImagesJob < ApplicationJob
    queue_as :import_variant_images
  
    def perform(product_id, variant_id)
        product = Product.find(product_id)
        variant = product.variants.find(variant_id)
        success, message = ApiImportVariantImages.call(product_id, variant_id)
        if success
            variant.update(status: "Finish")    
        # Turbo::StreamsChannel.broadcast_replace_to(
        #     product,
        #     target: "variant_#{variant_id}_product_#{product_id}",
        #     partial: "variants/variant",
        #     layout: false,
        #     locals: { variant: variant, product: product  }
        # )
        else
            variant.update(status: "Error")
        end
    end
end 