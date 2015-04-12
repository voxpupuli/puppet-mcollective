# private class
class mcollective::server::config::factsource::yaml {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $excluded_facts      = $mcollective::excluded_facts
  $yaml_fact_path_real = $mcollective::yaml_fact_path_real

  $cron_minute_offset  = fqdn_rand(15, ${::macaddress})
  $cron_minutes = [ $cron_minute_offset, $cron_minute_offset + 15, 
    $cron_minute_offset + 30, $cron_minute_offset + 45 ]

  # Template uses:
  #   - $yaml_fact_path_real
  file { "${mcollective::core_libdir}/refresh-mcollective-metadata":
    owner   => '0',
    group   => '0',
    mode    => '0755',
    content => template('mcollective/refresh-mcollective-metadata.erb'),
    before  => Cron['refresh-mcollective-metadata'],
  }
  cron { 'refresh-mcollective-metadata':
    environment => "PATH=/opt/puppet/bin:${::path}",
    command     => "${mcollective::core_libdir}/refresh-mcollective-metadata",
    user        => 'root',
    minute      => $cron_minutes,
  }
  exec { 'create-mcollective-metadata':
    path    => "/opt/puppet/bin:${::path}",
    command => "${mcollective::core_libdir}/refresh-mcollective-metadata",
    creates => $yaml_fact_path_real,
    require => File["${mcollective::core_libdir}/refresh-mcollective-metadata"],
  }

  mcollective::server::setting { 'factsource':
    value => 'yaml',
  }

  mcollective::server::setting { 'plugin.yaml':
    value => $yaml_fact_path_real,
  }
}
