# private class
class mcollective::common::config::connector::activemq {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  mcollective::common::setting { 'direct_addressing':
    value => 1,
  }

  if $mcollective::activemq_base64 {
    mcollective::common::setting { 'plugin.activemq.base64':
      value => 'yes',
    }
  }
  
  mcollective::common::setting { 'plugin.activemq.randomize':
    value => 'true',
  }

  $pool_size = size($mcollective::middleware_hosts)
  mcollective::common::setting { 'plugin.activemq.pool.size':
    value => $pool_size,
  }

  $indexes = range('1', $pool_size)
  mcollective::common::config::connector::activemq::hosts_iteration { $indexes: }
}
