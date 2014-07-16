# private class
class mcollective::server {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  anchor { 'mcollective::server::begin': } ->
  class { '::mcollective::server::install': } ->
  class { '::mcollective::server::config': } ~>
  class { '::mcollective::server::service':
    service_name => $mcollective::service_name,
  } ->
  anchor { 'mcollective::server::end': }
}
