#
class site_mcollective($middleware_hosts = [ 'localhost' ]) {
  class { '::mcollective':
      client             => true,
      server             => true,
      middleware         => true,
      middleware_hosts   => $middleware_hosts,
      securityprovider   => 'ssl',
      middleware_ssl     => true,
      ssl_client_certs   => "puppet:///modules/${module_name}/certs",
      ssl_ca_cert        => "puppet:///modules/${module_name}/certs/ca.pem",
      ssl_server_public  => "puppet:///modules/${module_name}/certs/server.pem",
      ssl_server_private => "puppet:///modules/${module_name}/private_keys/server.pem",
  }
}
