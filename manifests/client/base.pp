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

  anchor { "mcollective::client::base::begin": }
  anchor { "mcollective::client::base::end": }

  class { 'mcollective::client::package':
    version => $version,
    require => Anchor['mcollective::client::base::begin'],
  }
  class { 'mcollective::client::config':
    config      => $config,
    config_file => $config_file,
    require     => Class['mcollective::client::package'],
    before      => Anchor['mcollective::client::base::end'],
  }

}

