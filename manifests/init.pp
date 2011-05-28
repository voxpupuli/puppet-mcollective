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
#  [*pkg_provider*]       - The package provider resource to use.
#  [*stomp_server*]       - The hostname of the stomp server.
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
#     pkg_provider        => 'yum',
#     stomp_server        => 'stomp',
#   }
# }
#
class mcollective(
  $version               = 'UNSET',
  $server                = true,
  $server_config         = template('mcollective/server.cfg.erb'),
  $server_config_file    = '/etc/mcollective/server.cfg',
  $client                = true,
  $client_config         = template('mcollective/client.cfg.erb'),
  $client_config_file    = '/etc/mcollective/client.cfg',
  $pkg_provider          = $mcollective::params::pkg_provider,
  $stomp_server          = $mcollective::params::stomp_server
) inherits mcollective::params {

  $v_bool = [ '^true$', '^false$' ]
  $provider_ensure = [ '^yum$', '^aptitude$', '^pkgdmg$', '^appdmg$' ]
  validate_re($server_config_file, '^/')
  validate_re($client_config_file, '^/')
  validate_re("$server", $v_bool)
  validate_re("$client", $v_bool)
  validate_re($pkg_provider, $provider_ensure)
  validate_re($version, '^[._0-9a-zA-Z:-]+$')


  $server_real               = $server
  $client_real               = $client
  $client_config_file_real   = $client_config_file
  $server_config_file_real   = $server_config_file
  $server_config_real        = $server_config
  $client_config_real        = $client_config
  $pkg_provider_real         = $pkg_provider
  $stomp_server_real         = $stomp_server

  if $version == 'UNSET' {
      $version_real = 'present'
  } else {
      $version_real = $version
  }

  if $server_real {
    class { 'mcollective::server::base':
      version        => $version_real,
      pkg_provider   => $pkg_provider,
      config         => $server_config_real,
      config_file    => $server_config_file_real,
    }
  }

  if $client_real {
    class { 'mcollective::client::base':
      version        => $version_real,
      pkg_provider   => $pkg_provider,
      config         => $client_config_real,
      config_file    => $client_config_file_real,
    }
  }

}
