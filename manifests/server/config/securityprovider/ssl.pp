# private class
class mcollective::server::config::securityprovider::ssl {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { '/etc/mcollective/clients':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    purge   => true,
    recurse => true,
    mode    => '0400',
    source  => $mcollective::ssl_client_certs,
  }

  mcollective::server::setting { 'plugin.ssl_client_cert_dir':
    value => '/etc/mcollective/clients',
  }

  mcollective::server::setting { 'plugin.ssl_server_public':
    value => '/etc/mcollective/server_public.pem',
  }

  mcollective::server::setting { 'plugin.ssl_server_private':
    value => '/etc/mcollective/server_private.pem',
  }
}
