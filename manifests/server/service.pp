# private class
class mcollective::server::service($service_name) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  service { $service_name:
    ensure => 'running',
    enable => true,
  }
}
