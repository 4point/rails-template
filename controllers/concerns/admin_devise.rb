module AdminDevise
  extend ActiveSupport::Concern

  def after_sign_in_path_for(resource_or_scope)
    '/admin'
  end
end