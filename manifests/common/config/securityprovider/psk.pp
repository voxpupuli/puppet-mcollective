# private class
class mcollective::common::config::securityprovider::psk {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  mcollective::common::setting { 'plugin.psk':
    value => $mcollective::psk,
  }
}
