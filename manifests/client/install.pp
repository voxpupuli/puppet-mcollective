# private class
class mcollective::client::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }
  $mcollective_packages = ['mcollective-client','mcollective-puppet-agent','mcollective-puppet-client']
  if $mcollective::manage_packages {
    package { $mcollective_packages:
      ensure => $mcollective::version,
    }
  }
}
