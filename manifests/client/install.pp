# private class
class mcollective::client::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $mcollective::manage_packages {
    # prevent conflict where client package name == server package name
    if $mcollective::client_package != $mcollective::server_package {
      package { $mcollective::client_package:
        ensure => $mcollective::version,
      }
    }
  }
}
