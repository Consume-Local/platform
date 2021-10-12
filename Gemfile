source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.2', '>= 6.0.2.2'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 5.5'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
gem 'image_processing', '~> 1.2'

# CSS frameworks
gem "normalize-rails"

gem "autoprefixer-rails"

gem "uglifier", ">= 1.3.0"

# Use AWS S3 as the storage provider for ActiveStorage:
gem 'aws-sdk-s3', '~> 1.57', require: false

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  gem "bullet"

  # Use Pry as your rails console
  gem 'pry-rails', '~> 0.3.9'

  # Combine 'pry' with 'byebug'. Adds 'step', 'next', 'finish', 'continue' and
  # 'break' commands to control execution.
  gem 'pry-byebug', '~> 3.8'

  gem "factory_bot_rails"
  gem "rspec-rails", "~> 3.8"
  gem "ffaker"
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem 'selenium-webdriver', '~> 3.142', '>= 3.142.7'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Support for Ruby IDE tools - including "Ruby for Visual Studio Code"
  gem 'debase', '~> 0.2.4.1'
  gem 'reek', '~> 5.6'
  gem 'rubocop', '~> 0.80.0'
  gem 'ruby-debug-ide', '~> 0.7.0'

  # IDE tools for code completion, inline documentation, and static analysis
  gem 'solargraph', '~> 0.38.5'
end

group :test do
  gem "shoulda-matchers"

  # Generate test coverage reports:
  gem 'simplecov', '~> 0.17.1'

  # Format test coverage reports for console output:
  gem 'simplecov-console', '~> 0.7.2', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem "devise"