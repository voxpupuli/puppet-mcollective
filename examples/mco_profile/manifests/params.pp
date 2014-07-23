# This class exists solely to aggregate the set of information that tie
# together the MCollective middleware.
#
class mco_profile::params (
  $main_collective           = 'mcollective',
  $collectives               = undef,
  $middleware_hosts          = undef,
  $middleware_user           = 'mcollective',
  $middleware_password       = 'mcollective',
  $middleware_ssl_port       = '61613',
  $ssl_server_public         = "${::settings::ssldir}/public_keys/${::clientcert}.pem",
  $ssl_server_private        = "${::settings::ssldir}/private_keys/${::clientcert}.pem",
  $ssl_server_cert           = "${::settings::ssldir}/certs/${::clientcert}.pem",
  $ssl_ca_cert               = "${::settings::ssldir}/certs/ca.pem",
  $connector                 = undef,
  $middleware_admin_user     = 'admin',
  $middleware_admin_password = 'mcollective',
  $rabbitmq_vhost            = '/mcollective',
) {

  # No resources are declared by this class. It should only be used to set
  # Hiera parameters to propagate to inheriting classes.

}
