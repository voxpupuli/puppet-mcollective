# private class
class mcollective::common::config::securityprovider::ssl {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  mcollective::common::setting { 'plugin.ssl_ca_cert':
    value => "${mcollective::confdir}/ca.pem",
  }

  mcollective::common::setting { 'plugin.ssl_server_public':
    value => "${mcollective::confdir}/server_public.pem",
  }

  mcollective::common::setting { 'plugin.ssl_server_private':
    value => "${mcollective::confdir}/server_private.pem",
  }
}
