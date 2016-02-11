# private class
class mcollective::common::config::connector::activemq {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  mcollective::common::setting { 'direct_addressing':
    value => 1,
  }

  mcollective::common::setting { 'plugin.activemq.base64':
    value => yes,
  }

  mcollective::common::setting { 'plugin.activemq.randomize':
    value => true,
  }

  $pool_size = size(flatten([$mcollective::middleware_hosts]))
  mcollective::common::setting { 'plugin.activemq.pool.size':
    value => $pool_size,
  }

  $indexes = mco_array_to_string(range('1', $pool_size))
  mcollective::common::config::connector::activemq::hosts_iteration { $indexes: }

  mcollective::common::setting { 'plugin.activemq.heartbeat_interval':
    value => $mcollective::middleware_heartbeat_interval,
  }

}
