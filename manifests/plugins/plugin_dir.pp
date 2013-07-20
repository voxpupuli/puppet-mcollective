define mcollective::plugins::plugin_dir (
  $client = false) {

  $module_source = 'puppet:///modules/mcollective/plugins'

  $notify = $client ? {
    false   => Class[mcollective::server::service],
    default => undef,
  }

  file {"${mcollective::params::plugin_base}/${name}":
    ensure  => directory,
    source  => "${module_source}/${name}",
    recurse => true,
    notify  => $notify,
  }
}
