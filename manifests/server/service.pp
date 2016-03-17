# private class
class mcollective::server::service {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  service { $mcollective::service_name:
    ensure => $mcollective::service_ensure,
    enable => $mcollective::service_enable,
  }
}
