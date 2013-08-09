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
#  [*mw_server*]       - The hostname of the stomp server.
#  [*mc_security_provider*] - The MCollective security provider
#  [*mc_security_psk*]    - The MCollective pre shared key
#  [*registration*]       - Registration plugin to be used
#  [*main_collective]     - Sets the default collective
#  [*collectives]         - Sets the collectives a server node belongs to
#  [*connector]           - The stomp connector to use. Currently only stomp and
#                           activemq are recognized. Note activemq only supported
#                           on version 1.3.2+
#  [*direct_addressing*]  - Enable or disable direct addressing. If not set
#                           then defaults to 0 when using stomp connector and 1
#                           when using other connectors.
#  [*mw_server]        - Name or ip of stomp server
#  [*mw_port]          - Port on stomp server to connect to
#  [*mw_user]          - Username used to authenticate on stomp server
#  [*mw_passwd]        - Password used to authenticate on stomp server
#  [*mw_pool]          - A hash used to supply all parameters needed for advanced
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
#   class['stdlib']
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
#     mw_server           => 'stomp',
#   }
# }
#
# To setup stomp failover pools, ssl and plugin parameters:
# node default {
#   $mw_server1 = { host1 => 'stomp1', port1 => '61612', user1 => 'mcollective',
#     password1 => 'marionette'}
#   $mw_server2 = { host2 => 'stomp2', port2 => '6163', user2 => 'mcollective',
#     password2 => 'marionette', ssl2 => 'true' }
#
#   class {
#     mcollective:
#       mw_pool => { pool1 => $mw_server1, pool2 => $mw_server2 },
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
  $direct_addressing    = 'UNSET',
  $rabbitmq_vhost       = '/mcollective',
  $classesfile          = '/var/lib/puppet/state/classes.txt',
  $mw_pool              = {},
  $mw_server            = $mcollective::params::mw_server,
  $mw_port              = $mcollective::params::mw_port,
  $mw_user              = $mcollective::params::mw_user,
  $mw_passwd            = $mcollective::params::mw_passwd,
  $mc_security_provider = $mcollective::params::mc_security_provider,
  $mc_security_psk      = $mcollective::params::mc_security_psk,
  $registration         = $mcollective::params::registration,
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
  validate_re($connector, '^stomp$|^activemq$|^rabbitmq$')
  validate_hash($plugin_params)

  $server_real               = $server
  $client_real               = $client
  $client_config_file_real   = $client_config_file
  $server_config_file_real   = $server_config_file
  $mw_server_real         = $mw_server
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
  if empty($mw_pool) {
    if $connector == 'stomp' {
      $mw_pool_real = {
        1 => { host1     => $mw_server,
               port1     => $mw_port,
               user1     => $mw_user,
               password1 => $mw_passwd }
      }
    } else {
      $mw_pool_real = {
        1 => { host     => $mw_server,
               port     => $mw_port,
               user     => $mw_user,
               password => $mw_passwd }
      }
    }
  }
  else {
    validate_hash( $mw_pool )
    validate_hash( $mw_pool['pool1'] )
    $mw_pool_real = $mw_pool
  }
  $mw_pool_size = size(keys($mw_pool_real))

  if $direct_addressing == 'UNSET' {
    if $connector == 'stomp' {
      $direct_addressing_real = 0
    } else {
      $direct_addressing_real = 1
    }
  } else {
    $direct_addressing_real = $direct_addressing
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

