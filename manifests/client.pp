# private class
# Installs the client and sets up /etc/mcollective/client.cfg (global/common
# configuration)
class mcollective::client {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  contain ::mcollective::client::install
  contain ::mcollective::client::config

  Class['mcollective::client::install'] ->
  Class['mcollective::client::config']
}
