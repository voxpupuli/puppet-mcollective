class site::rabbitmq_broker (
  $delete_guest_user = false,
  $rabbitmq_confdir  = '/etc/rabbitmq',
) inherits site {

  file { "${rabbitmq_confdir}/ca.pem":
    owner  => 'rabbitmq',
    group  => 'rabbitmq',
    mode   => '0444',
    source => $site::ssl_ca_cert,
  }

  file { "${rabbitmq_confdir}/server_public.pem":
    owner  => 'rabbitmq',
    group  => 'rabbitmq',
    mode   => '0444',
    source => $site::ssl_server_public,
  }

  file { "${rabbitmq_confdir}/server_private.pem":
    owner  => 'rabbitmq',
    group  => 'rabbitmq',
    mode   => '0400',
    source => $site::ssl_server_private,
  }

  class { '::rabbitmq':
    config_stomp      => true,
    delete_guest_user => $delete_guest_user,
    ssl               => true,
    stomp_port        => $site::middleware_port,
    ssl_stomp_port    => $site::middleware_ssl_port,
    ssl_cacert        => "${rabbitmq_confdir}/ca.pem",
    ssl_cert          => "${rabbitmq_confdir}/server_public.pem",
    ssl_key           => "${rabbitmq_confdir}/server_private.pem",
  }

  rabbitmq_plugin { 'rabbitmq_stomp':
    ensure => present,
  } ->

  rabbitmq_vhost { $site::rabbitmq_vhost:
    ensure => present,
  } ->

  rabbitmq_user { $site::middleware_user:
    ensure   => present,
    admin    => false,
    password => $site::middleware_password,
  } ->

  rabbitmq_user { $site::middleware_admin_user:
    ensure   => present,
    admin    => true,
    password => $site::middleware_admin_password,
  } ->

  rabbitmq_user_permissions { "${site::middleware_user}@${site::rabbitmq_vhost}":
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
  } ->

  rabbitmq_user_permissions { "${site::middleware_admin_user}@${site::rabbitmq_vhost}":
    configure_permission => '.*',
  } ->

  rabbitmq_exchange { "mcollective_broadcast@${site::rabbitmq_vhost}":
    ensure   => present,
    type     => 'topic',
    user     => $site::middleware_admin_user,
    password => $site::middleware_admin_password,
  } ->

  rabbitmq_exchange { "mcollective_directed@${site::rabbitmq_vhost}":
    ensure   => present,
    type     => 'direct',
    user     => $site::middleware_admin_user,
    password => $site::middleware_admin_password,
  }

  contain rabbitmq

}
