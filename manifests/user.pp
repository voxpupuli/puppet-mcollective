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
  $public_key = undef,
  $public_key_content  = undef,
  $sshkey_learn_public_keys      =   false,
  $sshkey_overwrite_stored_keys  =   false,
  $sshkey_publickey_dir          =   "${mcollective::confdir}/sshkey_pubkeys",
  $sshkey_enable_private_key     =   false,
  $sshkey_known_hosts            =   "${homedir}/${callerid}/.ssh/known_hosts",
  $sshkey_enable_send_key        =   false,

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
    "${homedir}/.mcollective.d/credentials/public_keys",
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
  
  if $securityprovider == 'ssl' or  $securityprovider == 'sshkey' {
    $private_path = "${homedir}/.mcollective.d/credentials/private_keys/${callerid}.pem"
    if $private_key {
      file { $private_path:
        source =>  $private_key,
        owner  =>  $username,
        group  =>  $group,
        mode   =>  '0400',
      }
    }
    elsif $private_key_content {
      file { $private_path:
        content => $private_key_content,
        owner   => $username,
        group   => $group,
        mode    => '0400',
      }
    }
    elsif $securityprovider == 'ssl' {
      fail("A private key was not provided for user: ${username}")
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
  
  if $securityprovider == 'sshkey' {
    $public_path = "${homedir}/.mcollective.d/credentials/public_keys/${callerid}.pem"
    if $public_key {
      file { $public_path:
        source => $public_key,
        owner  => $username,
        group  => $group,
        mode   => '0400',
      }
    }
    elsif $public_key_content {
      file { $public_path:
        content => $public_key_content,
        owner   => $username,
        group   => $group,
        mode    => '0400',
      }
    }
    else { 
      exec { "recreate-public-key-${username}":
        path    => '/usr/bin:/usr/local/bin',
        command => "ssh-keygen -y -N '' -f ${private_path} > ${public_path}",
        unless  => "/usr/bin/test -e ${public_path}",
        require => File[ $private_path ],
      }
    }
    
    mcollective::user::setting { "${username}:plugin.sshkey.client.learn_public_keys":
      setting  => 'plugin.sshkey.client.learn_public_keys',
      username => $username,
      value    => bool2num($sshkey_learn_public_keys),
    }
    
    mcollective::user::setting { "${username}:plugin.sshkey.client.overwrite_stored_keys":
      setting  => 'plugin.sshkey.client.overwrite_stored_keys',
      username => $username,
      value    => bool2num($sshkey_overwrite_stored_keys),
    }
    
    mcollective::user::setting { "${username}:plugin.sshkey.client.publickey_dir":
      setting  => 'plugin.sshkey.client.publickey_dir',
      username => $username,
      value    => $sshkey_publickey_dir,
    }
    
    if $sshkey_enable_private_key {
      mcollective::user::setting { "${username}:plugin.sshkey.client.private_key":
        setting  => 'plugin.sshkey.client.private_key',
        username => $username,
        value    => $private_path,
      }
    }
    
    mcollective::user::setting { "${username}:plugin.sshkey.client.known_hosts":
      setting  => 'plugin.sshkey.client.known_hosts',
      username => $username,
      value    => $sshkey_known_hosts,
    }
    
    if $sshkey_enable_send_key {
      mcollective::user::setting { "${username}:plugin.sshkey.client.send_key":
        setting  => 'plugin.sshkey.client.send_key',
        username => $username,
        value    => $public_path,
      }
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
