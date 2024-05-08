class ApiLoadVariantsJob < ApplicationJob
    queue_as :load_variants
  
    def perform(product_id)
      # Do something later
        product = Product.find_by_id(product_id)
        message = ApiLoadVariants.call(product_id)
        Turbo::StreamsChannel.broadcast_update_to(
            product,
            target: "modal",
            partial: "shared/flash",
            layout: false,
            html: message.join('<br>').html_safe
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