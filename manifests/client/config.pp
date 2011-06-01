# Class: mcollective::client::config
#
#   This class installs the MCollective client configuration files.
#
# Parameters:
#
#  [*config*]               - The content of the MCollective client
#                             configuration file.
#  [*config_file*]          - The full path to the MCollective client
#                             configuration file.
#  [*client_config_owner*]  - The owner of the server configuration file.
#  [*client_config_group*]  - The group for the server configuration file.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mcollective::client::config(
  $config_file,
  $config,
  $client_config_owner   = $mcollective::params::client_config_owner,
  $client_config_group   = $mcollective::params::client_config_group
) inherits mcollective::params {

  file { 'client_config':
    path    => $config_file,
    content => $config,
    mode    => '0600',
    owner   => $client_config_owner,
    group   => $client_config_group,
  }

}

