# Class: mcollective::pkg_server
#
#   Manage the packages for the MCollective server
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
define mcollective::pkg(
  $version = 'UNSET',
  $ensure  = 'present'
) {

  # FIXME Should validate
  $version_real = $version ? {
    'UNSET' => 'installed',
    default => $version,
  }

  $v_ensure = [ 'present', 'absent' ]
  validate_re($ensure, $v_ensure)
  $ensure_real = $ensure ? {
    'present' => $version_real,
    'absent'  => 'absent',
  }

  package { $name:
    ensure => $ensure_real,
  }

}
