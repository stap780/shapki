class ImportConnectImageJob < ApplicationJob
    queue_as :link_import_image
  
    def perform(product_id)
      # Do something later
        product = Product.find_by_id(product_id)
        success, message = ApiLoadVariants.call(product_id)
        if success
            product.update(status: "Finish")    
            # Turbo::StreamsChannel.broadcast_update_to(
            #     product,
            #     target: "modal",
            #     partial: "shared/flash",
            #     layout: false,
            #     html: message.join('<br>').html_safe
            # )
        else
            product.update(status: "Error")
        end
    end
end 