class ApiImportVariantImagesJob < ApplicationJob
    queue_as :import_variant_images
  
    def perform(product_id, variant_id)
        product = Product.find(product_id)
        variant = product.variants.find(variant_id)
        ApiImportVariantImages.call(product_id, variant_id)

      # Do something later
        # message = ApiLoadVariants.call(product.uid)
        Turbo::StreamsChannel.broadcast_replace_to(
            product,
            target: "variant_#{variant_id}_product_#{product_id}",
            partial: "variants/variant",
            layout: false,
            locals: { variant: variant, product: product  }
        )
    #     variant.update!(status: "Load")
    #     # ExportNotifier.with(record: export, message: "ExportJob success").deliver(User.find_by_id(current_user_id))
  
        # Turbo::StreamsChannel.broadcast_replace_to(
        #   User.find(current_user_id),
        #   "exports",
        #   target: "export_#{export.id}",
        #   partial: "exports/export",
        #   layout: false,
        #   locals: {export: export}
        # )
    #   else
    #     variant.update!(status: "Error")
    end
end 