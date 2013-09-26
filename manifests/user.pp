# Define - mcollective::user
define mcollective::user(
  $username = $name,
  $group    = $name,
  $homedir = "/home/${name}",
  $certificate = undef,
  $private_key = undef,

  # duplication of $ssl_ca_cert, $ssl_server_public, $connector,
  # $middleware_ssl, $middleware_hosts, and $securityprovider parameters to
  # allow for spec testing.  These are otherwise considered private.
  $ssl_ca_cert = $mcollective::ssl_ca_cert,
  $ssl_server_public = $mcollective::ssl_server_public,
  $middleware_hosts = $mcollective::middleware_hosts,
  $middleware_ssl = $mcollective::middleware_ssl,
  $securityprovider = $mcollective::securityprovider,
  $connector = $mcollective::connector,
) {
  file { [
    "${homedir}/.mcollective.d",
    "${homedir}/.mcollective.d/credentials",
    "${homedir}/.mcollective.d/credentials/certs",
    "${homedir}/.mcollective.d/credentials/private_keys"
  ]:
    ensure => 'directory',
    owner  => $username,
    group  => $group,
  }

  datacat { "mcollective::user ${username}":
    path     => "${homedir}/.mcollective",
    collects => [ 'mcollective::user', 'mcollective::client' ],
    owner    => $username,
    group    => $group,
    mode     => '0400',
    template => 'mcollective/settings.cfg.erb',
  }

  if $middleware_ssl or $securityprovider == 'ssl' {
    file { "${homedir}/.mcollective.d/credentials/certs/ca.pem":
      source => $ssl_ca_cert,
      owner  => $username,
      group  => $group,
      mode   => '0444',
    }

    file { "${homedir}/.mcollective.d/credentials/certs/server_public.pem":
      source => $ssl_server_public,
      owner  => $username,
      group  => $group,
      mode   => '0444',
    }

    $private_path = "${homedir}/.mcollective.d/credentials/private_keys/${username}.pem"
    file { $private_path:
      source => $private_key,
      owner  => $username,
      group  => $group,
      mode   => '0400',
    }
  }

  if $securityprovider == 'ssl' {
    file { "${homedir}/.mcollective.d/credentials/certs/${username}.pem":
      source => $certificate,
      owner  => $username,
      group  => $group,
      mode   => '0444',
    }

    mcollective::user::setting { "${username}:plugin.ssl_client_public":
      setting  => 'plugin.ssl_client_public',
      username => $username,
      value    => "${homedir}/.mcollective.d/credentials/certs/${username}.pem",
      order    => '60',
    }

    mcollective::user::setting { "${username}:plugin.ssl_client_private":
      setting  => 'plugin.ssl_client_private',
      username => $username,
      value    => "${homedir}/.mcollective.d/credentials/private_keys/${username}.pem",
      order    => '60',
    }

    mcollective::user::setting { "${username}:plugin.ssl_server_public":
      setting  => 'plugin.ssl_server_public',
      username => $username,
      value    => "${homedir}/.mcollective.d/credentials/certs/server_public.pem",
      order    => '60',
    }
  }

  # This is specific to connector, but refers to the user's certs
  if $connector in [ 'activemq', 'rabbitmq' ] {
    $pool_size = size( $middleware_hosts )
    $hosts = range( '1', $pool_size )
    $connectors = prefix( $hosts, "${username}_" )
    mcollective::user::connector { $connectors:
      username       => $username,
      homedir        => $homedir,
      connector      => $connector,
      middleware_ssl => $middleware_ssl,
      order          => '60',
    }
  }
}
