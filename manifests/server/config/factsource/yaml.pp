# private class
class mcollective::server::config::factsource::yaml {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $excluded_facts      = $mcollective::excluded_facts
  $yaml_fact_path_real = $mcollective::yaml_fact_path_real
  $yaml_fact_cron      = $mcollective::yaml_fact_cron

  # Template uses:
  #   - $yaml_fact_path_real
  file { "${mcollective::site_libdir}/refresh-mcollective-metadata":
    owner   => '0',
    group   => '0',
    mode    => '0755',
    content => template('mcollective/refresh-mcollective-metadata.erb'),
  }
  if $yaml_fact_cron {
    cron { 'refresh-mcollective-metadata':
      environment => "PATH=/opt/puppet/bin:${::path}",
      command     => "${mcollective::core_libdir}/refresh-mcollective-metadata",
      user        => 'root',
      minute      => [ '0', '15', '30', '45' ],
      require     => File["${mcollective::core_libdir}/refresh-mcollective-metadata"],
    }
  }
  exec { 'create-mcollective-metadata':
    path    => "/opt/puppet/bin:${::path}",
    command => "${mcollective::site_libdir}/refresh-mcollective-metadata",
    creates => $yaml_fact_path_real,
    require => File["${mcollective::site_libdir}/refresh-mcollective-metadata"],
  }

  mcollective::server::setting { 'factsource':
    value => 'yaml',
  }

  mcollective::server::setting { 'plugin.yaml':
    value => $yaml_fact_path_real,
  }
}
