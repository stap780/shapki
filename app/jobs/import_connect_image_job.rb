class ImportConnectImageJob < ApplicationJob
    queue_as :link_import_image
  
    def perform(import_id)
      # Do something later
        import = Import.find_by_id(import_id)
        success, message = ImportConnectImage.call(import_id)
        if success
            import.update(status: "Finish")    
            # Turbo::StreamsChannel.broadcast_update_to(
            #     product,
            #     target: "modal",
            #     partial: "shared/flash",
            #     layout: false,
            #     html: message.join('<br>').html_safe
            # )
        else
            import.update(status: "Error")
        end
    end
end 