# Class: mcollective::service
#
#   This class manages the MCollective service.
#
#   Jeff McCune <jeff@puppetlabs.com>
#
#   This is seperate from the main mcollective class to enable other resources
#   to insert themselves after the main class and before the service. 
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mcollective::service($ensure='UNSET') inherits mcollective::params {
  notify { "FIXME: mcollective::service unimplemented": }

  if $ensure in [ 'running', 'UNSET' ] {
    $ensure_real = 'running'
    $enable_real = true
  } elsif $ensure in [ 'stopped' ] {
    $ensure_real = 'stopped'
    $enable_real = false
  } else {
    fail("ensure parameter must be running or stopped, got: ${ensure}")
  }

  service { 'mcollective':
    ensure     => $ensure_real,
    enable     => $enable_real,
    hasstatus  => true,
    hasrestart => true,
  }

}
