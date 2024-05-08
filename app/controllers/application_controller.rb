class ApplicationController < ActionController::Base
    before_action :configure_permitted_parameters, if: :devise_controller?

    def render_turbo_flash
      turbo_stream.update("our_flash", partial: "shared/flash")
    end



    protected

    def configure_permitted_parameters
      attributes = [:email] #[:name, :email]
      devise_parameter_sanitizer.permit(:sign_up, keys: attributes)
    end
    
end
