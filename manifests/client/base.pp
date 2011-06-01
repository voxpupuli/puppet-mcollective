# Class: mcollective::client::base
#
#   This class installs the MCollective client component for your nodes.
#
# Parameters:
#
#  [*version*]            - The version of the MCollective package(s) to
#                             be installed.
#  [*config*]             - The content of the MCollective client configuration
#                             file.
#  [*config_file*]        - The full path to the MCollective client
#                             configuration file.
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mcollective::client::base(
  $version,
  $config,
  $config_file
) inherits mcollective::params {

  class { 'mcollective::client::package':
    version      => $version,
  }
  class { 'mcollective::client::config':
    config      => $config,
    config_file => $config_file,
    require     => Class['mcollective::client::package'],
  }

}

