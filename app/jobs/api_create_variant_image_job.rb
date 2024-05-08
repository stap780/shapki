class ApiCreateVariantImageJob < ApplicationJob
    queue_as :create_variant_image
  
    def perform(product_id, variant_id)
      # Do something later
      product = Product.find_by_id(product_id)
      variant = product.variants.find_by_id(variant_id)
      ApiCreateVariantImage.call(product.uid, variant.uid, variant.images)
  
      Turbo::StreamsChannel.broadcast_replace_to(
        product,
        target: "variant_#{variant_id}_product_#{product_id}",
        partial: "variants/variant",
        layout: false,
        locals: { variant: variant, product: product  }
      )
      # if success
      #   variant.update(status: "Finish")
      #   # ExportNotifier.with(record: export, message: "ExportJob success").deliver(User.find_by_id(current_user_id))
  
      #   # Turbo::StreamsChannel.broadcast_replace_to(
      #   #   User.find(current_user_id),
      #   #   "exports",
      #   #   target: "export_#{export.id}",
      #   #   partial: "exports/export",
      #   #   layout: false,
      #   #   locals: {export: export}
      #   # )
      # else
      #   variant.update(status: "Error")
      # end
    end
end