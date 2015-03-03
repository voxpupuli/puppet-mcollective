# private class
class mcollective::common::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $mcollective::manage_packages {
    package { $mcollective::common_package:
      ensure => $mcollective::version,
    }
  }
}
