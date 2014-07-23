# This class should be applied to all servers, and sets up the MCollective
# server. It includes its parent class "site" and uses the parameters set
# there. Inheritance is used to ensure order of evaluation and exposition of
# parameters without needing to call "include".
#
class site::mco_server inherits site {

  class { '::mcollective':
    securityprovider     => 'ssl',
    middleware_ssl       => true,
    middleware_hosts     => $site::middleware_hosts,
    middleware_ssl_port  => $site::middleware_ssl_port,
    middleware_user      => $site::middleware_username,
    middleware_password  => $site::middleware_password,
    ssl_ca_cert          => "${settings::ssldir}/certs/ca.pem",
    main_collective      => $site::main_collective,
    collectives          => $site::collectives,
    connector            => $site::connector,
    ssl_server_public    => $site::ssl_server_public,
    ssl_server_private   => $site::ssl_server_private,
    ssl_server_ca        => $site::ssl_server_ca,
  }

}
