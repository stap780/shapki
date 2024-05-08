# class Myapp < InsalesApi::App
#     self.api_key = '1f60d74b05e210db3322887c4ccb5628'
# end
  
# Myapp.configure_api('myshop-bcp747.myinsales.ru', '0f835e6bffb533075da0fc99bf1ef82a')


# def self.shapki
#     puts 'старт '+Time.now.to_s
#     # api_key = "1f60d74b05e210db3322887c4ccb5628"
#     # password = "0f835e6bffb533075da0fc99bf1ef82a"
#     # domain = "myshop-bcp747.myinsales.ru"
#     current_process = "start shapki #{Time.now.to_s}"
# # 		CaseMailer.notifier_process(current_process).deliver_now
    
#     api_key = MyApp.api_key
#     domain = InsalesApi::App.api_host
#     password = InsalesApi::App.api_secret 				  
#     count = InsalesApi::Product.count
#     puts count
#     page = 1
#     while count > 0
#         products = InsalesApi::Product.find( :all,:params => {:limit => 100, :page=> page})
#         products.each do |pr|
#             if pr.variants.size > 1
#             puts "pr.id - "+pr.id.to_s
#                 pr.variants.each do |var|
#                     if var.barcode
#                     puts "var.id - "+var.id.to_s
#                         search_images = pr.images.select{ |image| image.filename.include?(var.barcode) }.map(&:id)
#                         var.image_ids = search_images
#                         var.save
#                         puts 'var.save - sleep 0.30'
#                         sleep 0.30
#                     end
#                 end
#             end
#         end
#     count = count - 100
#     page = page + 1
#     sleep 0.30
#     puts 'sleep 0.30'
#     end
#     puts 'finish '+Time.now.to_s
    
#     current_process = "finish shapki #{Time.now.to_s}"
# # 		CaseMailer.notifier_process(current_process).deliver_now
# end
