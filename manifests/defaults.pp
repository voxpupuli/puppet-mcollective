# private class
# This class is for setting the few platform defaults that need branching; all
# other configuration should be defaulted using the class paramaters to the
# mcollective class.
# Never refer to $mcollective::defaults::foo values outside of a parameter
# list, it's leak and prevents users from actually having control.
class mcollective::defaults {
  if versioncmp($::puppetversion, '4') < 0 {
    $confdir = '/etc/mcollective'
    $_core_libdir = $::osfamily ? {
      'Debian'  => '/usr/share/mcollective/plugins',
      'OpenBSD' => '/usr/local/libexec/mcollective',
      default   => '/usr/libexec/mcollective',
    }
    # Where this module will sync file-managed plugins to.
    # These paths may need revisiting by someone who understands FHS and
    # distribution standards for site-specific application-specific
    # library paths.
    $site_libdir = $::osfamily ? {
      'Debian'  => '/usr/local/share/mcollective',
      'OpenBSD' => regsubst($::rubyversion, '^(\d+)\.(\d+)\.(\d+)$', '/usr/local/lib/ruby/vendor_ruby/\1.\2/mcollective'),
      default   => '/usr/local/libexec/mcollective',
    }
  } else {
    $confdir     = '/etc/puppetlabs/mcollective'
    $_core_libdir = '/opt/puppetlabs/mcollective/plugins'
    $site_libdir = '/opt/puppetlabs/mcollective'
  }

  # Since mcollective version 2.8, there is no core libdir
  # https://docs.puppetlabs.com/mcollective/releasenotes.html#libdirloadpath-changes-and-core-plugins
  $mco_assumed_version = '2.8.5'

  $_mco_version = defined('$mco_version') ? {
    true    => $::mco_version,
    default => $mco_assumed_version,
  }
  if versioncmp($_mco_version, '2.8') >= 0 {
    $core_libdir = undef
  } else {
    $core_libdir = $_core_libdir
  }

  if ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '14.10') <= 0){
    $server_daemonize = false # See https://tickets.puppetlabs.com/browse/MCO-167
  } else {
    $server_daemonize = true
  }

  if defined('$is_pe') and str2bool($::is_pe) {
    $ruby_interpreter = '/opt/puppet/bin/ruby'
  } else {
    case $::operatingsystem {
      'OpenBSD': {
        $ruby_interpreter = regsubst($::rubyversion, '^(\d+)\.(\d+)\.(\d+)$', '/usr/local/bin/ruby\1\2')
      }
      default: {
        $ruby_interpreter = '/usr/bin/env ruby'
      }
    }
  }
}
