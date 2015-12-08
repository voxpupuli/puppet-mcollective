# private class
# This class is for setting the few platform defaults that need branching; all
# other configuration should be defaulted using the class paramaters to the
# mcollective class.
# Never refer to $mcollective::defaults::foo values outside of a parameter
# list, it's leak and prevents users from actually having control.
class mcollective::defaults {
  if versioncmp($::puppetversion, '4') < 0 {
    $confdir = '/etc/mcollective'
    $core_libdir = $::osfamily ? {
      'Debian' => '/usr/share/mcollective/plugins',
      default  => '/usr/libexec/mcollective',
    }
    # Where this module will sync file-managed plugins to.
    # These paths may need revisiting by someone who understands FHS and
    # distribution standards for site-specific application-specific
    # library paths.
    $site_libdir = $::osfamily ? {
      'Debian' => '/usr/local/share/mcollective',
      default  => '/usr/local/libexec/mcollective',
    }
  } else {
    $confdir     = '/etc/puppetlabs/mcollective'
    $core_libdir = '/opt/puppetlabs/mcollective/plugins'
    $site_libdir = '/opt/puppetlabs/mcollective'
  }

  if ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '14.10') <= 0){
    $server_daemonize = false # See https://tickets.puppetlabs.com/browse/MCO-167
  }
  else {
    $server_daemonize = true
  }

}
