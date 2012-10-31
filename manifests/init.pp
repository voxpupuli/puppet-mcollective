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
#  [*manage_packages]     - Boolean determining whether module should install
#                           required packages
#  [*manage_plugins]      - Boolean controlling installation of plugins in module
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
#  [*main_collective]     - Sets the default collective
#  [*collectives]         - Sets the collectives a server node belongs to
#  [*connector]           - The stomp connector to use. Currently only stomp and
#                           activemq are recognized. Note activemq only supported
#                           on version 1.3.2+
#  [*stomp_server]        - Name or ip of stomp server
#  [*stomp_port]          - Port on stomp server to connect to
#  [*stomp_user]          - Username used to authenticate on stomp server
#  [*stomp_passwd]        - Password used to authenticate on stomp server
#  [*stomp_pool]          - A hash used to supply all parameters needed for advanced
#                           features like failover pools and ssl
#  [*classesfile]         - Path to the classes file written by puppet
#  [*fact_source]         - The type of fact source. Currently only facter and yaml
#                           are recognized
#  [*yaml_facter_source]  - List of colon separated yaml files used by yaml fact source
#  [*plugin_params]       - Hash of parameters passed to mcollective plugins
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
# To setup stomp failover pools, ssl and plugin parameters:
# node default {
#   $stomp_server1 = { host1 => 'stomp1', port1 => '61612', user1 => 'mcollective',
#     password1 => 'marionette'}
#   $stomp_server2 = { host2 => 'stomp2', port2 => '6163', user2 => 'mcollective',
#     password2 => 'marionette', ssl2 => 'true' }
#
#   class {
#     mcollective:
#       stomp_pool => { pool1 => $stomp_server1, pool2 => $stomp_server2 },
#       plugin_params => { 'puppetd.puppetd' => '/usr/bin/puppet agent' }
#   }
# }
#
class mcollective(
  $version              = 'UNSET',
  $enterprise           = false,
  $manage_packages      = true,
  $manage_plugins       = false,
  $server               = true,
  $server_config        = 'UNSET',
  $server_config_file   = '/etc/mcollective/server.cfg',
  $client               = false,
  $client_config        = 'UNSET',
  $client_config_file   = '/etc/mcollective/client.cfg',
  $main_collective      = 'mcollective',
  $collectives          = 'mcollective',
  $connector            = 'stomp',
  $classesfile          = '/var/lib/puppet/state/classes.txt',
  $stomp_pool           = {},
  $stomp_server         = $mcollective::params::stomp_server,
  $stomp_port           = $mcollective::params::stomp_port,
  $stomp_user           = $mcollective::params::stomp_user,
  $stomp_passwd         = $mcollective::params::stomp_passwd,
  $mc_security_provider = $mcollective::params::mc_security_provider,
  $mc_security_psk      = $mcollective::params::mc_security_psk,
  $fact_source          = 'facter',
  $yaml_facter_source   = '/etc/mcollective/facts.yaml',
  $plugin_params        = {}
) inherits mcollective::params
{
  $v_bool = [ '^true$', '^false$' ]
  validate_bool($manage_packages)
  validate_bool($enterprise)
  validate_bool($manage_plugins)
  validate_re($server_config_file, '^/')
  validate_re($client_config_file, '^/')
  validate_re("$server", $v_bool)
  validate_re("$client", $v_bool)
  validate_re($version, '^[._0-9a-zA-Z:-]+$')
  validate_re($mc_security_provider, '^[a-zA-Z0-9_]+$')
  validate_re($mc_security_psk, '^[^ \t]+$')
  validate_re($fact_source, '^facter$|^yaml$')
  validate_re($connector, '^stomp$|^activemq$')
  validate_hash($plugin_params)

  $server_real               = $server
  $client_real               = $client
  $client_config_file_real   = $client_config_file
  $server_config_file_real   = $server_config_file
  $stomp_server_real         = $stomp_server
  $mc_security_provider_real = $mc_security_provider
  $mc_security_psk_real      = $mc_security_psk

  # Service Name:
  $service_name = $enterprise ? {
    true  => 'pe-mcollective',
    false => 'mcollective',
  }

  if $version == 'UNSET' {
      $version_real = 'present'
  } else {
      $version_real = $version
  }

  # if no pool hash is provided, create a single pool using defaults
  if $stomp_pool == 'UNSET' {
    $stomp_pool_real = {
      pool1 => { host1 => $stomp_server, port1 => $stomp_port, user1 => $stomp_user,
                 passwd1 => $stomp_passwd  }
    }
  }
  else {
    validate_hash( $stomp_pool )
    validate_hash( $stomp_pool['pool1'] )
    $stomp_pool_real = $stomp_pool
  }
  $stomp_pool_size = size(keys($stomp_pool_real))

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

  # Add anchor resources for containment
  anchor { 'mcollective::begin': }
  anchor { 'mcollective::end': }

  if $server_real {
    class { 'mcollective::server::base':
      version         => $version_real,
      enterprise      => $enterprise,
      manage_packages => $manage_packages,
      service_name    => $service_name,
      config          => $server_config_real,
      config_file     => $server_config_file_real,
      require         => Anchor['mcollective::begin'],
    }
    # Also manage the plugins
    if $manage_plugins {
      class { 'mcollective::plugins':
        require => Class['mcollective::server::base'],
        before  => Anchor['mcollective::end'],
      }
    }
  }

  if $client_real {
    class { 'mcollective::client::base':
      version         => $version_real,
      config          => $client_config_real,
      config_file     => $client_config_file_real,
      manage_packages => $manage_packages,
      require         => Anchor['mcollective::begin'],
      before          => Anchor['mcollective::end'],
    }
  }

}

