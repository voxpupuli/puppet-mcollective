#
class mcollective::server::config::registration::redis {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  mcollective::server::setting { 'registerinterval':
    value => 10,
  }

  mcollective::server::setting { 'registration':
    value => 'redis',
  }

  mcollective::plugin { 'registration/redis': }
}
