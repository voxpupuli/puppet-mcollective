# Class: mcollective
#
# This module manages MCollective.
#
# Parameters:
#
#  [*version*]            - The version of the MCollective package(s) to
#                             be installed.
#  [*server*]             - Boolean determining whether you would like to
#                             install the server component.
#  [*server_config*]      - The content of the MCollective server configuration
#                             file.
#  [*server_config_file*] - The full path to the MCollective server
#                             configuration file.
#  [*client*]             - Boolean determining whether you would like to
#                             install the client component.
#  [*client_config*]      - The content of the MCollective client configuration
#                             file.
#  [*client_config_file*] - The full path to the MCollective client
#                             configuration file.
#  [*stomp_server*]       - The hostname of the stomp server.
#  [*mc_security_provider*] - The MCollective security provider
#  [*mc_security_psk*]    - The MCollective pre shared key
#
# Actions:
#
# Requires:
#
#   Class['java']
#   Class['activemq']
#
# Sample Usage:
#
# The module works with sensible defaults:
#
# node default {
#   include mcollective
# }
#
# These defaults are:
#
# node default {
#   class { 'mcollective':
#     version             => 'present',
#     server              => true,
#     server_config       => template('mcollective/server.cfg.erb'),
#     server_config_file  => '/etc/mcollective/server.cfg',
#     client              => true,
#     client_config       => template('mcollective/client.cfg.erb'),
#     client_config_file  => '/home/mcollective/.mcollective',
#     stomp_server        => 'stomp',
#   }
# }
#
class mcollective(
  $version               = 'UNSET',
  $server                = true,
  $server_config         = 'UNSET',
  $server_config_file    = '/etc/mcollective/server.cfg',
  $client                = false,
  $client_config         = 'UNSET',
  $client_config_file    = '/etc/mcollective/client.cfg',
  $stomp_server          = $mcollective::params::stomp_server,
  $mc_security_provider  = $mcollective::params::mc_security_provider,
  $mc_security_psk       = $mcollective::params::mc_security_psk
) inherits mcollective::params {

  $v_bool = [ '^true$', '^false$' ]
  validate_re($server_config_file, '^/')
  validate_re($client_config_file, '^/')
  validate_re("$server", $v_bool)
  validate_re("$client", $v_bool)
  validate_re($version, '^[._0-9a-zA-Z:-]+$')
  validate_re($mc_security_provider, '^[a-zA-Z0-9_]+$')
  validate_re($mc_security_psk, '^[^ \t]+$')

  $server_real               = $server
  $client_real               = $client
  $client_config_file_real   = $client_config_file
  $server_config_file_real   = $server_config_file
  $stomp_server_real         = $stomp_server
  $mc_security_provider_real = $mc_security_provider
  $mc_security_psk_real      = $mc_security_psk

  if $version == 'UNSET' {
      $version_real = 'present'
  } else {
      $version_real = $version
  }

  if $client_config == 'UNSET' {
    $client_config_real = template('mcollective/client.cfg.erb')
  } else {
    $client_config_real = $client_config
  }
  if $server_config == 'UNSET' {
    $server_config_real = template('mcollective/server.cfg.erb')
  } else {
    $server_config_real = $server_config
  }

  if $server_real {
    class { 'mcollective::server::base':
      version        => $version_real,
      config         => $server_config_real,
      config_file    => $server_config_file_real,
    }
    # Also manage the plugins
    class { 'mcollective::plugins':
      require => Class['mcollective::server::base'],
    }
  }

  if $client_real {
    class { 'mcollective::client::base':
      version        => $version_real,
      config         => $client_config_real,
      config_file    => $client_config_file_real,
    }
  }

}

