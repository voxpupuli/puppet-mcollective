# private class
class mcollective::server::config::connector::activemq {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # Oh puppet!  Fake iteration of the indexes (+1 as plugin.activemq.pool is
  # 1-based)
  $pool_size = size($mcollective::middleware_hosts)
  $indexes = range('1', $pool_size)
  mcollective::server::config::connector::activemq::hosts_iteration { $indexes: }
}
