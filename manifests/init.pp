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
#  [*stomp_ip*]           - The IP address of the stomp server.
#  [*stomp_aliases*]      - Host aliases for the stomp server.
#
# Actions:
#
# Requires:
#
#   Class['stdlib::stages']
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
  $client                = false,
  $client_config         = template('mcollective/client.cfg.erb'),
  $client_config_file    = "/home/${mcollective::params::client_config_owner}/.mcollective",
  $pkg_provider          = $mcollective::params::pkg_provider,
  $stomp_server          = $mcollective::params::stomp_server,
  $stomp_ip              = $mcollective::params::stomp_ip,
  $stomp_aliases         = $mcollective::params::stomp_aliases
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
  $stomp_ip_real             = $stomp_ip
  $stomp_aliases_real        = $stomp_aliases



  }

  if $server_real {
    # Manage the package
    mcollective::pkg { 'mcollective':
      ensure  => present,
      version => $version_real,
      require => Mcollective::Pkg['mcollective-common'],
    }
    # Manage the configuration file
    file { '/etc/mcollective/server.cfg':
      ensure  => file,
      owner   => '0',
      group   => '0',
      mode    => '0640',
      content => $server_config_real,
      require => Mcollective::Pkg['mcollective'],
      notify  => Class['mcollective::service'],
    }
    # Manage the service
    class { 'mcollective::service':
      stage => 'deploy_infra',
    }
  }

  if $client_real {
    # Manage the package
    mcollective::pkg { 'mcollective-client':
      ensure  => present,
      version => $version_real,
      require => Mcollective::Pkg['mcollective-common'],
    }
    # Manage the configuration file
    file { '/etc/mcollective/client.cfg':
      ensure  => file,
      owner   => '0',
      group   => '0',
      mode    => '0640',
      content => $client_config_real,
      require => Mcollective::Pkg['mcollective-client'],
    }
  }

  # If the client OR the server is managed, we need to manage
  # all of the plugins as well.
  if $server_real or $client_real {
    class { 'mcollective::plugins':
      stage => 'setup_infra',
    }
  }

}

