class ApiLoadVariants < ApplicationService

    def initialize(product_id)
        Insale.api_init
        @product = Product.find_by_id(product_id)
        @ins_id = @product.uid
        @message = []
    end
  
    def call
      puts "ApiLoadVariants call"
      download_variants
      !@message.present? ? ["all_good"] : @message
    end
  
    private

    def download_variants
        pr = InsalesApi::Product.find(@ins_id)
        pr.variants.each do |var|
            variant = @product.variants.where(uid: var.id).first_or_create(uid: var.id, price: var.price, quantity: var.quantity, sku: var.sku, barcode: var.barcode)
            @message << (var.id.to_s+" =>"+variant.errors.full_messages.join) if variant.errors.present?
        end
    end

end