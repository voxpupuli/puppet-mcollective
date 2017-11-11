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
    value => bool2num($::mcollective::server_daemonize),
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

  file { $mcollective::ssldir:
    ensure => 'directory',
    owner  => 'root',
    group  => '0',
    mode   => '0755',
  }

  if $::mcollective::middleware_ssl {

    file { $::mcollective::middleware_ssl_ca_path:
      owner  => 'root',
      group  => '0',
      mode   => '0444',
      source => $::mcollective::middleware_ssl_ca_real,
    }

    file { $::mcollective::middleware_ssl_key_path:
      owner  => 'root',
      group  => '0',
      mode   => '0400',
      source => $::mcollective::middleware_ssl_key_real,
    }

    file { $::mcollective::middleware_ssl_cert_path:
      owner  => 'root',
      group  => '0',
      mode   => '0444',
      source => $::mcollective::middleware_ssl_cert_real,
    }

  }

  if $::mcollective::securityprovider == 'ssl' {

    file { $::mcollective::ssl_server_public_path:
      owner  => 'root',
      group  => '0',
      mode   => '0444',
      source => $::mcollective::ssl_server_public,
    }

    file { $::mcollective::ssl_server_private_path:
      owner  => 'root',
      group  => '0',
      mode   => '0400',
      source => $::mcollective::ssl_server_private,
    }

  }

  $middleware_multiple_ports = str2bool($mcollective::middleware_multiple_ports)

  if $middleware_multiple_ports {
    $pool_host_size = size(flatten([$mcollective::middleware_hosts]))
    $pool_port_size = $mcollective::middleware_ssl ? {
      true    => size(flatten([$mcollective::middleware_ssl_ports])),
      default => size(flatten([$mcollective::middleware_ports])),
    }

    if $pool_port_size != $pool_host_size {
      fail('Hosts and ports list must have the same length')
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
