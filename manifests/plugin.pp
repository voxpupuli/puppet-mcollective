#
define mcollective::plugin (
  $source         = undef,
  $package        = false,
  $type           = 'agent',
  $has_client     = true,
  # $client and $server are to allow for unit testing, and are considered private
  # parameters
  $client         = undef,
  $server         = undef,
  $package_ensure = 'present',
) {
  include ::mcollective

  $_client = pick_default($client, $::mcollective::client)
  $_server = pick_default($server, $::mcollective::server)

  if $package {
    # install from a package named "mcollective-${name}-${type}"
    $package_name = "mcollective-${name}-${type}"
    package { $package_name:
      ensure => $package_ensure,
    }

    if $_server {
      # set up a notification if we know we're managing a server
      Package[$package_name] ~> Class['mcollective::server::service']
    }

    # install the client package if we're installing on a $mcollective::client
    if $_client and $has_client {
      package { "mcollective-${name}-client":
        ensure => $package_ensure,
      }
    }
  } else {

    # file sync the module into mcollective::site_libdir
    if $source {
      $source_real = $source
    } else {
      $source_real = "puppet:///modules/mcollective/plugins/${name}"
    }

    datacat_fragment { "mcollective::plugin ${name}":
      target => 'mcollective::site_libdir',
      data   => {
        source_path => [ $source_real ],
      },
    }

  }
}
