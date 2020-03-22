class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    registration_attributes = [:first_name, :last_name]
    devise_parameter_sanitizer.permit(:sign_up, keys: registration_attributes)
    devise_parameter_sanitizer.permit(:account_update, keys: registration_attributes)
  end
end
