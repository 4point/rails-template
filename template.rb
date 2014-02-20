## Remove files
# no require_tree
gsub_file 'app/assets/javascripts/application.js', /= require_tree/, " require_tree"
gsub_file 'app/assets/stylesheets/application.css', /= require_tree/, " require_tree"

remove_file 'README.rdoc'
remove_file 'public/favicon.ico'

## Gems
# Remove Turbolinks
gsub_file 'Gemfile', /gem 'turbolinks'/, "# gem 'turbolinks'"
gsub_file 'app/assets/javascripts/application.js', /= require turbolinks/, " require turbolinks"

gem 'kaminari'
gem 'therubyracer' # or install nodejs
gem 'simple_form'
gem 'google-analytics-rails'
gem_group :development, :test do
  gem 'guard-livereload', require: false
  gem 'guard-rails', require: false
  gem 'meta_request'
end

## Generator
generate(:controller, "page index")

## Route
route "root 'page#index'"

## Copy files
# overwrite Thor's method, use this template's location
def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

copy_file 'layouts/application.html.erb', 'app/views/layouts/application.html.erb', :force => true
copy_file 'helpers/application_helper.rb', 'app/helpers/application_helper.rb', :force => true

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