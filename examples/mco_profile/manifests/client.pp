# an example profile for mco clients
class mco_profile::client (
  $middleware_hosts   = $mco_profile::params::middleware_hosts,
  $ssl_server_cert    = $mco_profile::params::ssl_server_cert,
  $ssl_server_private = $mco_profile::params::ssl_server_private,
  $ssl_server_public  = $mco_profile::params::ssl_server_public,
  $ssl_ca_cert        = $mco_profile::params::ssl_ca_cert,
  $connector          = $mco_profile::params::connector,
) {

  mcollective::user { "${::hostname}_client":
    homedir           => '/root',
    certificate       => $ssl_server_cert,
    private_key       => $ssl_server_private,
    ssl_ca_cert       => $ssl_ca_cert,
    ssl_server_public => $ssl_server_public,
    middleware_hosts  => $middleware_hosts,
    middleware_ssl    => true,
    securityprovider  => 'ssl',
    connector         => $connector,
  }

}
