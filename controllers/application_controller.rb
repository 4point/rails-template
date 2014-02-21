class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :backstage
  layout :layout_by_resource

  protected


  def backstage
    authenticate_admin! if request.path == "/admin/*"
  end

  def layout_by_resource
    if devise_controller?
      "application"
    elsif request.path == "/admin/*"
      "admin"
    else
      "application"
    end
  end
end