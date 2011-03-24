# Class: mcollective::params
#
#   This class provides parameters for all other classes in the mcollective
#   module.  This class should be inherited.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mcollective::params {

  case $operatingsystem {
    centos, redhat, oel: {
      $plugin_dir = '/usr/libexec/mcollective/mcollective'
    }
    debian, ubuntu: {
      $plugin_dir = '/usr/share/mcollective/plugins'
    }
    default: {
      fail("operatingsystem $operatingsystem is not supported")
    }
  }

}
