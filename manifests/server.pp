# private class
class mcollective::server {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if str2bool($mcollective::service_manage) {
    contain mcollective::server::service
  }

  contain mcollective::server::install
  contain mcollective::server::config

  Class['mcollective::server::install'] ->
  Class['mcollective::server::config']

  if str2bool($mcollective::service_manage) {
    contain mcollective::server::service
    Class['::mcollective::server::config'] ~>
    Class['mcollective::server::service']
  }
}

