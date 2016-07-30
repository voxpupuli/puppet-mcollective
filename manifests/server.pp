# private class
class mcollective::server {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  contain ::mcollective::server::install
  contain ::mcollective::server::config
  contain ::mcollective::server::service

  Class['mcollective::server::install'] ->
  Class['mcollective::server::config']  ~>
  Class['mcollective::server::service']
}
