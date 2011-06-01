# Class: mcollective::client::package
#
#   This class installs the MCollective client package and all dependencies.
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
class mcollective::client::package(
  $version
) {

  package { 'mcollective-client':
    ensure	  => $version,
  }
}

