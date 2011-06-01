# Class: mcollective::server::package::debian
#
#   This class installs MCollective dependency packages for Debian.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mcollective::server::package::debian(
  $version ) {

  package { 'mcollective':
    ensure	  => $version,
  }

  package { 'libstomp-ruby':
    ensure    => present,
  }
}

