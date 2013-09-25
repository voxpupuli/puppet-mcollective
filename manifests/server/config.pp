# private class
class mcollective::server::config {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  datacat { 'mcollective::server':
    owner    => 'root',
    group    => 'root',
    mode     => '0400',
    path     => $mcollective::server_config_file,
    template => 'mcollective/settings.cfg.erb',
  }

  mcollective::server::setting { 'classesfile':
    value => $mcollective::classesfile,
  }

  mcollective::server::setting { 'daemonize':
    value => $mcollective::server_daemonize,
  }

  mcollective::server::setting { 'logfile':
    value => $mcollective::server_logfile,
  }

  mcollective::server::setting { 'loglevel':
    value => $mcollective::server_loglevel,
  }

  file { '/etc/mcollective/policies':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  if $mcollective::middleware_ssl or $mcollective::securityprovider == 'ssl' {
    file { '/etc/mcollective/ca.pem':
      owner  => 'root',
      group  => 'root',
      mode   => '0444',
      source => $mcollective::ssl_ca_cert,
    }

    file { '/etc/mcollective/server_public.pem':
      owner  => 'root',
      group  => 'root',
      mode   => '0444',
      source => $mcollective::ssl_server_public,
    }

    file { '/etc/mcollective/server_private.pem':
      owner  => 'root',
      group  => 'root',
      mode   => '0400',
      source => $mcollective::ssl_server_private,
    }
  }

  mcollective::soft_include { [
    "::mcollective::server::config::connector::${mcollective::connector}",
    "::mcollective::server::config::securityprovider::${mcollective::securityprovider}",
    "::mcollective::server::config::factsource::${mcollective::factsource}",
    "::mcollective::server::config::registration::${mcollective::registration}",
    "::mcollective::server::config::rpcauditprovider::${mcollective::rpcauditprovider}",
    "::mcollective::server::config::rpcauthprovider::${mcollective::rpcauthprovider}",
  ]:
    start => Anchor['mcollective::server::config::begin'],
    end   => Anchor['mcollective::server::config::end'],
  }

  anchor { 'mcollective::server::config::begin': }
  anchor { 'mcollective::server::config::end': }
}
