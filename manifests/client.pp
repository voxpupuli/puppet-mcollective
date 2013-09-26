# private class
# Installs the client and sets up /etc/mcollective/client.cfg (global/common
# configuration)
class mcollective::client {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  anchor { 'mcollective::client::begin': } ->
  class { '::mcollective::client::install': } ->
  class { '::mcollective::client::config': } ->
  anchor { 'mcollective::client::end': }
}
