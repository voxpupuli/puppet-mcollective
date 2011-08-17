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
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mcollective::server::base(
  $version,
  $config,
  $enterprise,
  $manage_packages,
  $service_name,
  $config_file
) inherits mcollective::params {

  if $manage_packages {
    class { 'mcollective::server::package':
      version => $version,
      require => Anchor['mcollective::begin'],
      before  => Class['mcollective::server::config'],
      notify  => Class['mcollective::server::service'],
    }
  }
  class { 'mcollective::server::config':
    config      => $config,
    config_file => $config_file,
    require     => Anchor['mcollective::begin'],
  }
  if $enterprise {
    class { 'mcollective::server::service':
      mc_service_name  => $service_name,
      mc_service_stop  => false,
      mc_service_start => false,
      subscribe        => Class['mcollective::server::config'],
      before           => Anchor['mcollective::end'],
    }
  } else {
    class { 'mcollective::server::service':
      subscribe    => Class['mcollective::server::config'],
      before       => Anchor['mcollective::end'],
    }
  }
}

