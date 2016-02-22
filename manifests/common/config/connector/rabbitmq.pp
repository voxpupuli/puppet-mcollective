# private class
class mcollective::common::config::connector::rabbitmq {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  mcollective::common::setting { 'direct_addressing':
    value => 1,
  }

  mcollective::common::setting { 'plugin.rabbitmq.vhost':
    value => $mcollective::rabbitmq_vhost,
  }

  mcollective::common::setting { 'plugin.rabbitmq.randomize':
    value => true,
  }

  $pool_size = size(flatten([$mcollective::middleware_hosts]))
  mcollective::common::setting { 'plugin.rabbitmq.pool.size':
    value => $pool_size,
  }

  $indexes = mco_array_to_string(range('1', $pool_size))
  mcollective::common::config::connector::rabbitmq::hosts_iteration { $indexes: }

  mcollective::common::setting { 'plugin.rabbitmq.heartbeat_interval':
    value => $mcollective::middleware_heartbeat_interval,
  }

}
