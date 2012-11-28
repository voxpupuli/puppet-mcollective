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
  $mc_client_package = $osfamily ? {
    Linux   => undef,
    default => 'mcollective'
  }

  if $mc_client_package != undef {
    package { $mc_client_package:
      ensure	  => $version,
    }
  }
}

