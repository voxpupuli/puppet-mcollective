# private class
class mcollective::server::config::factsource::yaml {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $excluded_facts = $mcollective::excluded_facts

  # This pattern originally from
  # http://projects.puppetlabs.com/projects/mcollective-plugins/wiki/FactsFacterYAML
  file { $mcollective::yaml_fact_path:
    owner   => 'root',
    group   => '0',
    mode    => '0400',
    content => template('mcollective/facts.yaml.erb'),
  }

  mcollective::server::setting { 'factsource':
    value => 'yaml',
  }

  mcollective::server::setting { 'plugin.yaml':
    value =>  "${mcollective::yaml_fact_path}:${mcollective::extra_yaml_paths}"
  }
}
