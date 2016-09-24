# private class
class mcollective::server::config::rpcauditprovider::logfile {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  mcollective::server::setting { 'rpcauditprovider':
    value => 'logfile',
  }

  mcollective::server::setting { 'rpcaudit':
    value => 1,
  }

  mcollective::server::setting { 'plugin.rpcaudit.logfile':
    value => $mcollective::rpcauditlogfile,
  }
}
