name = ask("What is the name of this site ?")
create_file "config/settings.yml", "name: '#{name}'"

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

copy_file 'helpers/application_helper.rb', 'app/helpers/application_helper.rb', :force => true
copy_file 'initializers/settings.rb', 'config/initializers/settings.rb', :force => true

## Generator
generate(:controller, "page index")
generate(:controller, "admin index")

## Gems
# Remove Turbolinks
gsub_file 'Gemfile', /gem 'turbolinks'/, "# gem 'turbolinks'"
gsub_file 'app/assets/javascripts/application.js', /= require turbolinks/, " require turbolinks"

gem 'devise'
gem 'twitter-bootstrap-rails'
gem 'ransack'
gem 'carrierwave'
gem 'mysql2'
gem 'ckeditor_rails'
gem 'kaminari'
gem 'therubyracer' # or install nodejs
gem 'simple_form'
gem 'google-analytics-rails'
gem_group :development, :test do
  gem 'guard-livereload', require: false
  gem 'guard-rails', require: false
  gem 'meta_request'
end

## Admin
run 'bundle install'

generate('devise:install')
generate('devise Admin')
generate('devise:views')
generate('bootstrap:install')
generate('bootstrap:layout', 'application fixed -f')
generate('simple_form:install', '--bootstrap')
generate('kaminari:config')
rake 'db:migrate'

# add default admin account
append_file 'db/seeds.rb', "admins = Admin.create([{email: 'admin@example.com', password: 'admin@example.com', password_confirmation: 'admin@example.com'}])"
rake 'db:seed'

# add auth to default app controller
copy_file 'controllers/application_controller.rb', 'app/controllers/application_controller.rb', :force => true
copy_file 'controllers/admin_controller.rb', 'app/controllers/admin_controller.rb', :force => true

# kaminari per page 10
gsub_file 'config/initializers/kaminari_config.rb', /# config.default_per_page = 25/, "config.default_per_page = 10"

# devise use :get to sign out
gsub_file 'config/initializers/devise.rb', /config.sign_out_via = :delete/, "config.sign_out_via = :get"

# cancel devise admin registration
gsub_file 'app/models/admin.rb', /devise :database_authenticatable, :registerable,/, "devise :database_authenticatable, #:registerable,"
gsub_file 'config/routes.rb', /devise_for :admins/, "get 'admin' => 'admin#index'\n\tdevise_for :admins, :skip => [:registration]\n\tscope '/admin' do\n\tend\n\t"

# devise layout
gsub_file 'app/views/devise/sessions/new.html.erb', /f.submit "Sign in"/, 'f.submit "Sign in", :class => "btn btn-primary"'
gsub_file 'app/views/devise/sessions/new.html.erb', /f.submit "Send me reset password instructions"/, 'f.submit "Send me reset password instructions", :class => "btn btn-primary"'
gsub_file 'app/views/devise/passwords/edit.html.erb', /f.submit "Change my password"/, 'f.submit "Change my password", :class => "btn btn-primary"'
gsub_file 'app/views/devise/confirmations/new.html.erb', /f.submit "Resend confirmation instructions"/, 'f.submit "Resend confirmation instructions", :class => "btn btn-primary"'
gsub_file 'app/views/devise/registrations/edit.html.erb', /f.submit "Update"/, 'f.submit "Update", :class => "btn btn-primary"'
gsub_file 'app/views/devise/registrations/new.html.erb', /f.submit "Sign up"/, 'f.submit "Sign up", :class => "btn btn-primary"'
gsub_file 'app/views/devise/unlocks/new.html.erb', /f.submit "Resend unlock instructions"/, 'f.submit "Resend unlock instructions", :class => "btn btn-primary"'

# scaffold without scaffold.css
gsub_file 'config/application.rb', /config.assets.version = '1.0'/, "config.assets.version = '1.0'\n    config.generators do |g|\n        g.stylesheets false\n    end"

# fetch scaffold template
#directory 'templates/scaffold', 'lib/templates/erb/scaffold'
# fetch scaffold controller with kaminari
#directory 'templates/scaffold_controller', 'lib/templates/rails/scaffold_controller'

# copy files
directory 'lib', 'lib', :force => true
directory 'views/kaminari', 'app/views/kaminari'
directory 'locales', 'config/locales', :force => true
directory 'stylesheets', 'app/assets/stylesheets'
directory 'javascripts', 'app/assets/javascripts', :force => true
directory 'layouts', 'app/views/layouts', :force => true

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
