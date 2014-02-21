backend = yes?("Need Admin Stage?") ? true : false

## Remove files
# no require_tree
gsub_file 'app/assets/javascripts/application.js', /= require_tree/, " require_tree"
gsub_file 'app/assets/stylesheets/application.css', /= require_tree/, " require_tree"

remove_file 'README.rdoc'
remove_file 'public/favicon.ico'

## Copy files
# overwrite Thor's method, use this template's location
def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

copy_file 'layouts/application.html.erb', 'app/views/layouts/application.html.erb', :force => true
copy_file 'helpers/application_helper.rb', 'app/helpers/application_helper.rb', :force => true

## Generator
generate(:controller, "page index")

## Gems
# Remove Turbolinks
gsub_file 'Gemfile', /gem 'turbolinks'/, "# gem 'turbolinks'"
gsub_file 'app/assets/javascripts/application.js', /= require turbolinks/, " require turbolinks"

if backend
  gem 'devise'
  gem 'bootstrap-sass'
  gem 'ransack'
  gem 'carrierwave'
  gem 'mysql2'
  gem 'ckeditor_rails'
end

gem 'kaminari'
gem 'simple_form'
gem 'google-analytics-rails'
gem_group :development, :test do
  gem 'guard-livereload', require: false
  gem 'guard-rails', require: false
  gem 'meta_request'
end

## Admin
if backend
  run 'bundle install'

  generate('devise:install')
  generate('devise Admin')
  generate('devise:views')
  generate('kaminari:config')
  # bootstrap 3.x support not ready yet
  # generate('simple_form:install', '--bootstrap3')
  rake 'db:migrate'
  
  # add default admin account
  append_file 'db/seeds.rb', "admins = Admin.create([{email: 'admin@example.com', password: 'admin@example.com', password_confirmation: 'admin@example.com'}])"
  rake 'db:seed'
  
  # add auth to default app controller
  copy_file 'controllers/application_controller.rb', 'app/controllers/application_controller.rb', :force => true
  
  # use different layout for devise
  copy_file 'layouts/devise_layout.html.erb', 'app/views/layouts/devise_layout.html.erb', :force => true
  copy_file 'layouts/admin.html.erb', 'app/views/layouts/application.html.erb', :force => true
  
  # kaminari per page 10
  gsub_file 'config/initializers/kaminari_config.rb', /# config.default_per_page = 25/, "config.default_per_page = 10"
  
  # devise use :get to sign out
  gsub_file 'config/initializers/devise.rb', /config.sign_out_via = :delete/, "config.sign_out_via = :get"
  
  # cancel devise admin registration
  gsub_file 'app/models/admin.rb', /devise :database_authenticatable, :registerable,/, "devise :database_authenticatable, #:registerable,"
  gsub_file 'config/routes.rb', /devise_for :admins/, "devise_for :admins, :skip => [:registration]"
  
  # scaffold without scaffold.css
  gsub_file 'config/application.rb', /config.assets.version = '1.0'/, "config.assets.version = '1.0'\n    config.generators do |g|\n        g.stylesheets false\n    end"
  
  # apply css
  create_file 'app/assets/stylesheets/admin.scss', <<-CODE
//= require_self
//= require bootstrap
//input, textarea { width: auto; }
body { padding-top: 60px; }
CODE
  
  # apply js
  create_file 'app/assets/javascripts/admin.js', '//= require bootstrap'
  
  # fetch scaffold template
  directory 'templates/scaffold', 'lib/templates/erb/scaffold', :force => true
  
  # fetch scaffold controller with kaminari
  directory 'templates/scaffold_controller', 'lib/templates/rails/scaffold_controller'
  
  # fetch kaminari views
  directory 'views/kaminari', 'app/views/kaminari'
  
  # fetch zh-TW locales
  directory 'locales', 'config/locales', :force => true
  
  # fetch css
  # directory 'stylesheets', 'app/assets/stylesheets'
end

## Route
route "root 'page#index'"

## Git
# ignore
append_file '.gitignore', <<-CODE
*~
*.swp
CODE

# init
git :init
git :add => '.'
git :commit => "-a -m 'init'"