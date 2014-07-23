#!ruby
source 'https://rubygems.org'

group :development, :test do
  gem 'rake'
  gem 'puppetlabs_spec_helper'
  gem 'puppet-lint'
end

puppetversion = ENV['PUPPET_GEM_VERSION']

if puppetversion
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end
