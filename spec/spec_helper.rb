require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

RSpec.configure do |c|
  default_facts = {
    puppetversion: Puppet.version,
    facterversion: Facter.version
  }
  default_facts += YAML.read_file('default_facts.yml') if File.exist?('default_facts.yml')
  default_facts += YAML.read_file('default_facts.yml') if File.exist?('default_module_facts.yml')
  c.default_facts = default_facts
end

# vim: syntax=ruby
