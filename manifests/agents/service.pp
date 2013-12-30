# private class
class mcollective::agents::service {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  service { 'mcollective':
    ensure => 'running',
    enable => true,
  }
}
