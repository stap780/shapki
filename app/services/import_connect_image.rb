class ImportConnectImage < ApplicationService

    def initialize(import_id)
        Insale.api_init

    end
  
    def call
      puts "ImportConnectImage call"
      process
      !@message.present? ? [true, "all_good"] : [false, @message]
    end
  
    private

    def process

        
    end

end