#!ruby

source "https://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.7.0'
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "rspec-puppet-facts"
  gem "rspec", "< 3.2.0", { "platforms" => ["ruby_18"] }
  gem "puppet-blacksmith", "> 3.3.0", { "platforms" => ["ruby_19", "ruby_20", "ruby_21"] }
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "guard-rake"
end

group :system_tests do
  gem "beaker"
  gem "beaker-rspec"
end
