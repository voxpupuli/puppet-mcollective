# private class
class mcollective::server::config {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  datacat { 'mcollective::server':
    owner    => 'root',
    group    => '0',
    mode     => '0400',
    path     => $mcollective::server_config_file_real,
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

  file { "${mcollective::confdir}/policies":
    ensure => 'directory',
    owner  => 'root',
    group  => '0',
    mode   => '0700',
  }

  if $mcollective::middleware_ssl or $mcollective::securityprovider == 'ssl' {
    file { "${mcollective::confdir}/ca.pem":
      owner  => 'root',
      group  => '0',
      mode   => '0444',
      source => $mcollective::ssl_ca_cert,
    }

    file { "${mcollective::confdir}/server_public.pem":
      owner  => 'root',
      group  => '0',
      mode   => '0444',
      source => $mcollective::ssl_server_public,
    }

    file { "${mcollective::confdir}/server_private.pem":
      owner  => 'root',
      group  => '0',
      mode   => '0400',
      source => $mcollective::ssl_server_private,
    }

    file { "${mcollective::confdir}/shared_server_public.pem":
      owner  => 'root',
      group  => '0',
      mode   => '0444',
      source => $mcollective::ssl_shared_server_public_real,
    }

    file { "${mcollective::confdir}/shared_server_private.pem":
      owner  => 'root',
      group  => '0',
      mode   => '0400',
      source => $mcollective::ssl_shared_server_private_real,
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
