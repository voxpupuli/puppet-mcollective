# Class: mcollective::pkg::debian
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
class mcollective::pkg::debian {
  
  package { 'libstomp-ruby':
    ensure    => present,
  }
}