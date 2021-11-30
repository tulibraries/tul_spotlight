source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.5'

gem 'rails', '~> 6.0.4', '>= 6.0.4.1'
gem "mysql2", "~> 0.5.3"
gem 'puma', '~> 4.3.8'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 4.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem "pry-rails"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'blacklight', ' ~> 7.0'
gem 'blacklight-spotlight', github: 'projectblacklight/spotlight'
group :development, :test do
  gem 'solr_wrapper', '>= 0.3'
end

gem 'rsolr', '>= 1.0', '< 3'
gem 'bootstrap', '~> 4.0'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'jquery-rails'
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'coffee-rails', '~> 4.2'
gem 'uglifier', '>= 1.3.0'
gem 'friendly_id'
gem 'sitemap_generator'
gem 'blacklight-gallery', '~> 3.0'
gem 'openseadragon', '>= 0.2.0'
gem 'blacklight-oembed', '~> 1.0'
gem 'devise_invitable'
# Additional Gems for uploading assets
gem "mimemagic", "0.3.8"
gem "carrierwave", "2.2.2"
gem "nokogiri", "1.12.4"
gem "addressable", "2.8.0"
