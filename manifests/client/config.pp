# private class
class mcollective::client::config {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $mcollective::securityprovider == 'ssl' or $mcollective::securityprovider == 'sshkey' {
    # if using the ssl or sshkey securityprovider  each user will want their own ~/.mcollective
    # with their own identity in, so don't publish the global client.cfg
    file { 'mcollective::client':
      ensure => 'absent',
      path   => $mcollective::client_config_file_real,
    }
  }
  else {
    datacat { 'mcollective::client':
      owner    => 'root',
      group    => '0',
      mode     => '0444',
      path     => $mcollective::client_config_file_real,
      template => 'mcollective/settings.cfg.erb',
    }
  }

  mcollective::client::setting { 'loglevel':
    value => $mcollective::client_loglevel,
  }

  mcollective::client::setting { 'logger_type':
    value => $mcollective::client_logger_type,
  }

  mcollective::soft_include { [
    "::mcollective::client::config::connector::${mcollective::connector}",
    "::mcollective::client::config::securityprovider::${mcollective::securityprovider}",
  ]:
    start => Anchor['mcollective::client::config::begin'],
    end   => Anchor['mcollective::client::config::end'],
  }

  anchor { 'mcollective::client::config::begin': }
  anchor { 'mcollective::client::config::end': }
}
