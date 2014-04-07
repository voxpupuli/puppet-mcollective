# private class
class mcollective::client::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }
  packages = ['mcollective-client','mcollective-puppet-agent','mcollective-puppet-client']
  if $mcollective::manage_packages {
    package { $mcollective::client::install::packages:
      ensure => $mcollective::version,
    }
  }
}
