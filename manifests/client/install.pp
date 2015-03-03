# private class
class mcollective::client::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $mcollective::manage_packages {
    package { $mcollective::common_package:
      ensure => $mcollective::version,
    }
    ->
    package { $mcollective::client_package:
      ensure => $mcollective::version,
    }
  }
}
