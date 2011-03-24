# MCollective Module

Jeff McCune <jeff@puppetlabs.com>

This module manages MCollective from within Puppet.

# Quick Start

    class site_mcollective {
      class { 'mcollective': version => 'latest' }
      class { 'mcollective::service': }
    }
    include site_mcollective

# TODO

 - MCollective Client Management
 - Plugin Management (Facter integration)
 - Agent Management (puppetd)

Also, I plan to use git-subtree merge to pull in the upstream
mcollective-plugins directory.

