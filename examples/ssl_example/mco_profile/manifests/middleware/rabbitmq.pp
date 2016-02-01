# This class prepares a RabbitMQ middleware service for use by MCollective.
class mco_profile::middleware::rabbitmq (
  $confdir                   = '/etc/rabbitmq',
  $vhost                     = $mco_profile::params::rabbitmq_vhost,
  $delete_guest_user         = false,
  $ssl_ca_cert               = $mco_profile::params::ssl_ca_cert,
  $ssl_server_cert           = $mco_profile::params::ssl_server_cert,
  $ssl_server_private        = $mco_profile::params::ssl_server_private,
  $middleware_port           = $mco_profile::params::middleware_port,
  $middleware_ssl_port       = $mco_profile::params::middleware_ssl_port,
  $middleware_user           = $mco_profile::params::middleware_user,
  $middleware_password       = $mco_profile::params::middleware_password,
  $middleware_admin_user     = $mco_profile::params::middleware_admin_user,
  $middleware_admin_password = $mco_profile::params::middleware_admin_password,
) inherits mco_profile::params {

  # Set up SSL files. Use copies of the PEM keys specified as parameters.
  file { "${confdir}/ca.pem":
    owner  => 'rabbitmq',
    group  => 'rabbitmq',
    mode   => '0444',
    source => $ssl_ca_cert,
    notify => Service['rabbitmq-server'],
  }
  file { "${confdir}/server_cert.pem":
    owner  => 'rabbitmq',
    group  => 'rabbitmq',
    mode   => '0444',
    source => $ssl_server_cert,
    notify => Service['rabbitmq-server'],
  }
  file { "${confdir}/server_private.pem":
    owner  => 'rabbitmq',
    group  => 'rabbitmq',
    mode   => '0400',
    source => $ssl_server_private,
    notify => Service['rabbitmq-server'],
  }

  # Install the RabbitMQ service using the puppetlabs/rabbitmq module
  class { '::rabbitmq':
    config_stomp      => true,
    delete_guest_user => $delete_guest_user,
    ssl               => true,
    stomp_port        => $middleware_port,
    ssl_stomp_port    => $middleware_ssl_port,
    ssl_cacert        => "${confdir}/ca.pem",
    ssl_cert          => "${confdir}/server_cert.pem",
    ssl_key           => "${confdir}/server_private.pem",
  }
  contain ::rabbitmq

  # Configure the RabbitMQ service for use by MCollective
  rabbitmq_plugin { 'rabbitmq_stomp':
    ensure => present,
    notify => Service['rabbitmq-server'],
  }

  rabbitmq_vhost { $vhost:
    ensure => present,
    notify => Service['rabbitmq-server'],
  }

  rabbitmq_user { $middleware_user:
    ensure   => present,
    admin    => false,
    password => $middleware_password,
    notify   => Service['rabbitmq-server'],
  }
  rabbitmq_user { $middleware_admin_user:
    ensure   => present,
    admin    => true,
    password => $middleware_admin_password,
    notify   => Service['rabbitmq-server'],
  }

  rabbitmq_user_permissions { "${middleware_user}@${vhost}":
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
    notify               => Service['rabbitmq-server'],
  }
  rabbitmq_user_permissions { "${middleware_admin_user}@${vhost}":
    configure_permission => '.*',
    notify               => Service['rabbitmq-server'],
  }

  rabbitmq_exchange { "mcollective_broadcast@${vhost}":
    ensure   => present,
    type     => 'topic',
    user     => $middleware_admin_user,
    password => $middleware_admin_password,
  }
  rabbitmq_exchange { "mcollective_directed@${vhost}":
    ensure   => present,
    type     => 'direct',
    user     => $middleware_admin_user,
    password => $middleware_admin_password,
  }

}
