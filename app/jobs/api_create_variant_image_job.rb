class ApiCreateVariantImageJob < ApplicationJob
    queue_as :create_variant_image
  
    def perform(product_id, variant_id)
      product = Product.find_by_id(product_id)
      variant = product.variants.find_by_id(variant_id)
      variant.update(status: "Process")
      success, message = ApiCreateVariantImage.call(product.uid, variant.uid, variant.images)
  
      # Turbo::StreamsChannel.broadcast_replace_to(
      #   product,
      #   target: "variant_#{variant_id}_product_#{product_id}",
      #   partial: "variants/variant",
      #   layout: false,
      #   locals: { variant: variant, product: product  }
      # )

      if success
        variant.update(status: "Finish")
      else
        variant.update(status: "Error")
      end

    end
end