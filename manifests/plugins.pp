# Class: mcollective::plugins
#
#   This class deploys the default set of MCollective
#   plugins
#
# Parameters:
#
# Actions:
#
# Requires:
#
#   Class['mcollective']
#   Class['mcollective::service']
#
# Sample Usage:
#
#   This class is intended to be declared in the mcollective class.
#
class mcollective::plugins(
  $plugin_base = $mcollective::params::plugin_base,
  $plugin_subs = $mcollective::params::plugin_subs,
  $client = false
) inherits mcollective::params {

  File {
    owner  => '0',
    group  => '0',
    mode   => '0644',
    ignore => '.svn',
  }

  # $plugin_base and $plugin_subs are meant to be arrays.
  file { $plugin_base:
    ensure  => directory,
    require => Class['mcollective::server::package'],
  }

  # common directories
  mcollective::plugins::plugin_dir {$mcollective::params::plugin_server_subs: }

  # client directories
  mcollective::plugins::plugin_dir {$mcollective::params::plugin_client_subs: }
}

