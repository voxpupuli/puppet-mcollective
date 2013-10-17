#
class mcollective::middleware::rabbitmq {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $mcollective::middleware_ssl {
    file { "${mcollective::rabbitmq_confdir}/ca.pem":
      owner  => 'rabbitmq',
      group  => 'rabbitmq',
      mode   => '0444',
      source => $mcollective::ssl_ca_cert,
    }

    file { "${mcollective::rabbitmq_confdir}/server_public.pem":
      owner  => 'rabbitmq',
      group  => 'rabbitmq',
      mode   => '0444',
      source => $mcollective::ssl_server_public,
    }

    file { "${mcollective::rabbitmq_confdir}/server_private.pem":
      owner  => 'rabbitmq',
      group  => 'rabbitmq',
      mode   => '0400',
      source => $mcollective::ssl_server_private,
    }
  }

  anchor { 'mcollective::middleware::rabbitmq::start': }
  class { '::rabbitmq':
    erlang_manage     => true,
    config_stomp      => true,
    delete_guest_user => $mcollective::delete_guest_user,
    ssl               => $mcollective::middleware_ssl,
    stomp_port        => $mcollective::middleware_port,
    ssl_stomp_port    => $mcollective::middleware_ssl_port,
    ssl_cacert        => "${mcollective::rabbitmq_confdir}/ca.pem",
    ssl_cert          => "${mcollective::rabbitmq_confdir}/server_public.pem",
    ssl_key           => "${mcollective::rabbitmq_confdir}/server_private.pem",
  } ->

  rabbitmq_plugin { 'rabbitmq_stomp':
    ensure => present,
  } ->

  rabbitmq_vhost { $mcollective::rabbitmq_vhost:
    ensure => present,
  } ->

  rabbitmq_user { $mcollective::middleware_user:
    ensure   => present,
    admin    => false,
    password => $mcollective::middleware_password,
  } ->

  rabbitmq_user { $mcollective::middleware_admin_user:
    ensure   => present,
    admin    => true,
    password => $mcollective::middleware_admin_password,
  } ->

  rabbitmq_user_permissions { "${mcollective::middleware_user}@${mcollective::rabbitmq_vhost}":
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
  } ->

  rabbitmq_user_permissions { "${mcollective::middleware_admin_user}@${mcollective::rabbitmq_vhost}":
    configure_permission => '.*',
  } ->

  rabbitmq_exchange { "mcollective_broadcast@${mcollective::rabbitmq_vhost}":
    ensure   => present,
    type     => 'topic',
    user     => $mcollective::middleware_admin_user,
    password => $mcollective::middleware_admin_password,
  } ->

  rabbitmq_exchange { "mcollective_directed@${mcollective::rabbitmq_vhost}":
    ensure   => present,
    type     => 'direct',
    user     => $mcollective::middleware_admin_user,
    password => $mcollective::middleware_admin_password,
  } ->

  anchor { 'mcollective::middleware::rabbitmq::end': }
}
