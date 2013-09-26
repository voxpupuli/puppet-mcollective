# private class
class mcollective::server::config::factsource::yaml {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # This pattern originally from
  # http://projects.puppetlabs.com/projects/mcollective-plugins/wiki/FactsFacterYAML
  file { $mcollective::yaml_fact_path:
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => template('mcollective/facts.yaml.erb'),
  }

  mcollective::server::setting { 'factsource':
    value => 'yaml',
  }

  mcollective::server::setting { 'plugin.yaml':
    value => $mcollective::yaml_fact_path,
  }
}
