require 'rspec-system/spec_helper'
require 'rspec-system-puppet/helpers'

include RSpecSystemPuppet::Helpers

RSpec.configure do |c|
  # Project root for the firewall code
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Enable colour in Jenkins
  c.tty = true

  c.include RSpecSystemPuppet::Helpers

  # This is where we 'setup' the nodes before running our tests
  c.before :suite do
    puppet_install

    rcp(:source_path => proj_root + '/spec/fixtures/hiera.yaml',
        :destination_path => '/etc/puppet/hiera.yaml')

    rcp(:source_path => proj_root + '/spec/fixtures/data',
        :destination_path => '/etc/puppet/data')

    puppet_module_install(:source => proj_root, :module_name => 'mcollective')
    puppet_module_install(:source => proj_root + '/spec/fixtures/modules/site_mcollective', :module_name => 'site_mcollective')
    puppet_module_install(:source => proj_root + '/spec/fixtures/modules/site_nagios', :module_name => 'site_nagios')
    # XXX would be better if puppet_module_install parsed this out of the
    # Modulefile
    #
    shell 'puppet module install puppetlabs/activemq'
    shell 'puppet module install puppetlabs/java_ks'
    shell 'puppet module install puppetlabs/rabbitmq'
    shell 'puppet module install richardc/datacat'
  end
end
