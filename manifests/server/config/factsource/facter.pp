# private class
class mcollective::server::config::factsource::facter {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  mcollective::plugin { 'facter':
    type       => 'facts',
    package    => true,
    has_client => false,
  }

  mcollective::server::setting { 'factsource':
    value => 'facter',
  }

  mcollective::server::setting { 'fact_cache_time':
    value => 300,
  }
}
