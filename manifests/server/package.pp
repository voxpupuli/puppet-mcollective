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

  case $operatingsystem {
    debian,ubuntu: {
      class { 'mcollective::package::debian': }
    }
  }

}
