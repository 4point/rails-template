# bundle install first to fit new rails
run 'bundle install'

name = ask("What is the name of this site ?")
create_file "config/settings.yml", "name: '#{name}'"

# Create gemset
run "rvm gemset create #{name}"

# Add rvmrc file
create_file ".rvmrc", "rvm #{RUBY_VERSION}@#{name}\n"

## Remove files
# no require_tree
gsub_file 'app/assets/javascripts/application.js', /= require_tree/, " require_tree"
gsub_file 'app/assets/stylesheets/application.css', /= require_tree/, " require_tree"
inject_into_file 'app/assets/stylesheets/application.css', " *= require style\n", :after => " *= require_self\n"

remove_file 'README.rdoc'
remove_file 'public/favicon.ico'
remove_file 'app/views/layouts/application.html.erb'

## Copy files
# overwrite Thor's method, use this template's location
def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

copy_file 'helpers/application_helper.rb', 'app/helpers/application_helper.rb', :force => true
copy_file 'initializers/settings.rb', 'config/initializers/settings.rb', :force => true
copy_file 'initializers/assets.rb', 'config/initializers/assets.rb', :force => true

## Generator
generate(:controller, "page index")

## Gems
# Remove Turbolinks
gsub_file 'Gemfile', /gem 'turbolinks'/, "# gem 'turbolinks'"
gsub_file 'app/assets/javascripts/application.js', /= require turbolinks/, " require turbolinks"

gem 'haml'
gem 'devise'
gem 'bootstrap-sass'
gem 'ransack'
gem 'carrierwave'
gem 'mini_magick'
gem 'mysql2'
gem 'ckeditor_rails'
gem 'kaminari'
gem 'simple_form'
gem 'google-analytics-rails'
gem 'activerecord-session_store'
gem 'activeadmin', github: 'activeadmin'
gem 'active_skin'
gem_group :development, :test do
  gem 'brakeman', require: false
  gem "rack-livereload"
  gem 'guard-livereload', require: false
  gem 'guard-rails', require: false
  gem 'meta_request'
end

## Admin
run 'bundle install'

generate('active_admin:install', 'Admin')
generate('simple_form:install', '--bootstrap')
generate('kaminari:config')
rake 'db:migrate'

# add admin skin
append_file 'app/assets/stylesheets/active_admin.css.scss', '@import "active_skin";'

# add auth to default app controller
copy_file 'controllers/application_controller.rb', 'app/controllers/application_controller.rb', :force => true

# Generate session migration
generate('active_record:session_migration')

# Stores session in a database using Active Record
gsub_file 'config/initializers/session_store.rb', "Rails.application.config.session_store :cookie_store, key: '_#{name}_session'", 'Rails.application.config.session_store :active_record_store'

# kaminari per page 10
gsub_file 'config/initializers/kaminari_config.rb', /# config.default_per_page = 25/, "config.default_per_page = 10"

# set time_zone
gsub_file 'config/application.rb', /# config.time_zone = 'Central Time \(US & Canada\)'/, "config.time_zone = 'Asia/Taipei'"

# scaffold without scaffold.css
gsub_file 'config/application.rb', /config.assets.version = '1.0'/, "config.assets.version = '1.0'\n    config.generators do |g|\n        g.stylesheets false\n    end"

# scaffold without test
gsub_file 'config/application.rb', /# config.i18n.default_locale = :de/, "config.i18n.default_locale = 'zh-TW'\n    config.generators.assets = false\n    config.generators.helper = false\n    config.generators.test_framework = false"

# set production assets precompile
gsub_file 'config/environments/production.rb', /# config.assets.precompile/, 'config.assets.precompile'

# enable livereload
gsub_file 'config/environments/development.rb', /application.configure do/, "application.configure do\n  config.middleware.use Rack::LiveReload"

# copy files
directory 'views/kaminari', 'app/views/kaminari'
directory 'locales', 'config/locales', :force => true
directory 'layouts', 'app/views/layouts', :force => true
directory 'partials', 'app/views/partials', :force => true
directory 'stylesheets', 'app/assets/stylesheets'

# sacffold gen
generate('model site_block key:string:uniq content:text note:string') # site blocks
rake 'db:migrate'

## Route
route "root 'page#index'"

# Generate Guardfile
run 'guard init'

## Git
# ignore
append_file '.gitignore', <<-CODE
*~
*.swp
.DS_Store
CODE

# init
git :init
git :add => '.'
git :commit => "-a -m 'init'"
