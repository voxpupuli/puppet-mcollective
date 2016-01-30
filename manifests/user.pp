# Define - mcollective::user
define mcollective::user(
  $username = $name,
  $callerid = $name,
  $group    = $name,
  $homedir = "/home/${name}",
  $certificate = undef,
  $certificate_content  = undef,
  $private_key = undef,
  $private_key_content  = undef,

  # duplication of $ssl_ca_cert, $ssl_server_public,$ssl_server_private, $connector,
  # $middleware_ssl, $middleware_hosts, and $securityprovider parameters to
  # allow for spec testing.  These are otherwise considered private.
  $ssl_ca_cert = $mcollective::ssl_ca_cert,
  $ssl_server_public = $mcollective::ssl_server_public,
  $ssl_server_private = $mcollective::ssl_server_private,
  $middleware_hosts = $mcollective::middleware_hosts,
  $middleware_ssl = $mcollective::middleware_ssl,
  $securityprovider = $mcollective::securityprovider,
  $connector = $mcollective::connector,
) {
  
  # Validate that both forms of data weren't given
  if $certificate and $certificate_content {
    fail("Both a source and content cannot be defined for ${username} certificate!")
  }
  if $private_key and $private_key_content {
    fail("Both a source and content cannot be defined for ${username} private key!")
  }
  
  file { [
    "${homedir}/.mcollective.d",
    "${homedir}/.mcollective.d/credentials",
    "${homedir}/.mcollective.d/credentials/certs",
    "${homedir}/.mcollective.d/credentials/private_keys",
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
    
    file { "${homedir}/.mcollective.d/credentials/private_keys/server_private.pem":
      source => $ssl_server_private,
      owner  => $username,
      group  => $group,
      mode   => '0400',
    }
  }

  if $securityprovider == 'ssl' {
    $private_path = "${homedir}/.mcollective.d/credentials/private_keys/${callerid}.pem"
    $private_content = pick($private_key_content,file($private_key))
    file { $private_path:
      content => $private_content,
      owner   => $username,
      group   => $group,
      mode    => '0400',
    }
  }

  if $securityprovider == 'ssl' {
    $cert_content = pick($certificate_content, file($certificate))
    file { "${homedir}/.mcollective.d/credentials/certs/${callerid}.pem":
      content => $cert_content,
      owner   => $username,
      group   => $group,
      mode    => '0444',
    }

    mcollective::user::setting { "${username}:plugin.ssl_client_public":
      setting  => 'plugin.ssl_client_public',
      username => $username,
      value    => "${homedir}/.mcollective.d/credentials/certs/${callerid}.pem",
      order    => '60',
    }

    mcollective::user::setting { "${username}:plugin.ssl_client_private":
      setting  => 'plugin.ssl_client_private',
      username => $username,
      value    => "${homedir}/.mcollective.d/credentials/private_keys/${callerid}.pem",
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
    $pool_size = size(flatten([$middleware_hosts]))
    $hosts = range( '1', $pool_size )
    $connectors = prefix( $hosts, "${username}_" )
    mcollective::user::connector { $connectors:
      username       => $username,
      callerid       => $callerid,
      homedir        => $homedir,
      connector      => $connector,
      middleware_ssl => $middleware_ssl,
      order          => '60',
    }
  }
}
