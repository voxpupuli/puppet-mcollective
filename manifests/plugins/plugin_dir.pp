define mcollective::plugins::plugin_dir {
  file {"${mcollective::params::plugin_base}/${name}":
    ensure  => directory,
    source  => "puppet:///${::module_source}/${name}",
    recurse => true,
  }
}
