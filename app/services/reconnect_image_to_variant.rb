class ReconnectImageToVariant < ApplicationService
  
    def initialize(uid)
      Insale.api_init 
      @ins_id = uid
      @error_message = nil
    end
  
    def call
      puts "ReconnectImageToVariant call"
      result = set_variants_images
      if result
        true
      else
        false
      end
    end
  
    private

    def set_variants_images
        pr = InsalesApi::Product.find(@ins_id)
        if pr.variants.size > 0
            puts "pr.id - "+pr.id.to_s
            pr.variants.each do |var|
                if var.barcode
                    search_images = pr.images.select{ |image| image.filename.include?(var.barcode) }.map(&:id)
                    var.image_ids = search_images
                    var.save
                    puts "var.id - "+var.id.to_s
                    #puts 'var.save - sleep 0.30'
                    #sleep 0.30
                end
            end
        end
    end

end