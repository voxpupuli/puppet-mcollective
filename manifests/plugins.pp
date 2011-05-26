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
  $purge = true
) inherits mcollective::params {

  $v_bool = [ '^true$', '^false$' ]
  validate_re("$purge", $v_bool)
  $purge_real = $purge

  File {
    owner => '0',
    group => '0',
    mode  => '0644',
  }

  file { "${plugin_dir}":
    ensure  => directory,
    source  => "puppet:///modules/${module_name}/plugins",
    recurse => true,
    purge   => $purge_real,
    notify  => Class['mcollective::service'],
  }

}
