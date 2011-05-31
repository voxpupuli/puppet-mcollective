# Class: mcollective::server::config
#
#   This class installs the MCollective configuration files.
#
# Parameters:
#
#  [*config*]               - The content of the MCollective client
#                             configuration file.
#  [*config_file*]          - The full path to the MCollective client
#                             configuration file.
#  [*server_config_owner*]  - The owner of the server configuration file.
#  [*server_config_group*]  - The group for the server configuration file.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mcollective::server::config(
  $config_file,
  $config,
  $server_config_owner   = $mcollective::params::server_config_owner,
  $server_config_group   = $mcollective::params::server_config_group
) inherits mcollective::params {

  file { 'server_config':
    path    => $config_file,
    content => $config,
    mode    => '0640',
    owner   => $server_config_owner,
    group   => $server_config_group,
    notify  => Class['mcollective::server::service'],
  }

}
