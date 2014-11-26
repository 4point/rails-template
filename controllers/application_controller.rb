class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  layout :layout_by_resource

  before_filter :set_root_url

  protected

  def set_root_url
    # do not use HTTP_X_FORWARDED_HOST, will cause ip spoofing
    host = env['HTTP_HOST'] || "#{env['SERVER_NAME'] || env['SERVER_ADDR']}:#{env['SERVER_PORT']}"
    @_root_url = request.protocol + host
    @_full_url = @_root_url + request.fullpath
  end

  def layout_by_resource
    if devise_controller?
      "devise"
    elsif request.path.include?("admin/")
      "admin"
    else
      "application"
    end
  end

end
