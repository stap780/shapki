class ReconnectImageToVariantJob < ApplicationJob
    queue_as :reconnect_image
  
    def perform(product_id)
      # Do something later
      product = Product.find_by_id(product_id)
      success = ReconnectImageToVariant.call(product.uid)
  
      if success
        product.update(status: "Finish")
        # ExportNotifier.with(record: export, message: "ExportJob success").deliver(User.find_by_id(current_user_id))
  
        # Turbo::StreamsChannel.broadcast_replace_to(
        #   User.find(current_user_id),
        #   "exports",
        #   target: "export_#{export.id}",
        #   partial: "exports/export",
        #   layout: false,
        #   locals: {export: export}
        # )
      else
        product.update(status: "Error")
      end
    end
end