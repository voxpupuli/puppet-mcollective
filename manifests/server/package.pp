# Class: mcollective::server::package
#
#   This class installs the MCollective server package and all dependencies.
#
# Parameters:
#
#  [*version*]            - The version of the MCollective package(s) to
#                             be installed.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mcollective::server::package(
  $version
) {

  # The relationship to this class is required because other classes, e.g.
  # Class['mcollective::config'] requires the mcollective::server:package class.
  case $operatingsystem {
    debian,ubuntu: {
      class { 'mcollective::server::package::debian':
        version => $version,
        before  => Class['mcollective::server::package'],
      }
    }
    rhel,centos,oel: {
      class { 'mcollective::server::package::redhat':
        version => $version,
        before  => Class['mcollective::server::package'],
      }
    }
  }

}

