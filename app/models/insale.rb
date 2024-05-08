class Insale < ApplicationRecord
    validates :api_link, presence: true
    validates :api_key, presence: true
    validates :api_password, presence: true

    def self.api_init
        return false unless Insale.first.present?
        InsalesApi::App.api_key = Insale.first.api_key
        InsalesApi::App.configure_api(Insale.first.api_link, Insale.first.api_password)    
    end

    def self.api_work?
        return false unless Insale.first.present?

        Insale.api_init
        begin
            account = InsalesApi::Account.find
        rescue ActiveResource::ResourceNotFound
            #redirect_to :action => 'not_found'
            puts  'not_found 404'
            false
        rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
            #redirect_to :action => 'new'
            puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
            false
        rescue ActiveResource::UnauthorizedAccess
            puts "Failed.  Response code = 401.  Response message = Unauthorized"
            false
        rescue ActiveResource::ForbiddenAccess
            puts "Failed.  Response code = 403.  Response message = Forbidden."
            false
        else
            account
        end
        account.blocked == false ? true : false
    end

end
