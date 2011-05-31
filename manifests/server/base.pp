# Class: mcollective::server::base
#
#   This class installs the MCollective server component for your nodes.
#
# Parameters:
#
#  [*version*]            - The version of the MCollective package(s) to
#                             be installed.
#  [*config*]             - The content of the MCollective client configuration
#                             file.
#  [*config_file*]        - The full path to the MCollective client
#                             configuration file.
#  [*pkg_provider*]       - The package provider resource to use.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mcollective::server::base(
  $version,
  $config,
  $config_file,
  $pkg_provider = $mcollective::params::pkg_provider
) inherits mcollective::params {

  class { 'mcollective::server::pkg':
    version      => $version,
    pkg_provider => $pkg_provider,
  }
  class { 'mcollective::server::config':
    config      => $config,
    config_file => $config_file,
    require     => Class['mcollective::server::pkg'],
  }
  class { 'mcollective::server::service':
    require => [ Class['mcollective::server::config'],
                 Class['mcollective::server::pkg'], ],
  }

}
