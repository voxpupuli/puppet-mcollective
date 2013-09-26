#
define mcollective::plugin(
  $source = undef,
  $package = false,
  $type = 'agent',
  $has_client = true,
  # $client is to allow for unit testing, and considered a private
  # parameter
  $client = $mcollective::client,
) {
  if $package {
    # install from a package named "mcollective-${name}-${type}
    package { "mcollective-${name}-${type}":
      ensure => 'present',
    }

    # install the client package if we're installing on a $mcollective::client
    if $client and $has_client {
      package { "mcollective-${name}-client":
        ensure => 'present',
      }
    }
  }
  else {
    # file sync the module into mcollective::site_libdir
    if $source {
      $source_real = $source
    }
    else {
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
