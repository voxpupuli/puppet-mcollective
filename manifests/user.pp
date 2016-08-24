# Define - mcollective::user
define mcollective::user(
  $username    = $name,
  $callerid    = $name,
  $group       = $name,
  $homedir     = "/home/${name}",
  $certificate = undef,
  $certificate_content  = undef,
  $private_key = undef,
  $private_key_content  = undef,
  $public_key = undef,
  $public_key_content  = undef,
  $sshkey_learn_public_keys      =   false,
  $sshkey_overwrite_stored_keys  =   false,
  $sshkey_publickey_dir          =   undef,
  $sshkey_enable_private_key     =   false,
  $sshkey_known_hosts            =   undef,
  $sshkey_enable_send_key        =   false,

  # duplication of $ssl_ca_cert, $ssl_server_public, $ssl_server_private, $connector,
  # $middleware_ssl, $middleware_hosts, and $securityprovider parameters to
  # allow for spec testing.  These are otherwise considered private.
  $ssl_ca_cert       = undef,
  $ssl_server_public = undef,
  $ssl_server_private= undef,
  $middleware_hosts  = undef,
  $middleware_ssl    = undef,
  $securityprovider  = undef,
  $connector         = undef,
  $ssl_ciphers       = undef,
) {

  include ::mcollective

  $_middleware_ssl    = pick_default($middleware_ssl, $::mcollective::middleware_ssl)
  $_ssl_ca_cert       = pick_default($ssl_ca_cert, $::mcollective::ssl_ca_cert)
  $_ssl_server_public = pick_default($ssl_server_public, $::mcollective::ssl_server_public)
  $_ssl_server_private= pick_default($ssl_server_private, $::mcollective::ssl_server_private)
  $_middleware_hosts  = pick_default($middleware_hosts, $::mcollective::middleware_hosts)
  $_securityprovider  = pick_default($securityprovider, $::mcollective::securityprovider)
  $_connector         = pick_default($connector, $::mcollective::connector)
  $_ssl_ciphers       = pick_default($ssl_ciphers, $::mcollective::ssl_ciphers)

  # Validate that both forms of data weren't given
  if $certificate and $certificate_content {
    fail("Both a source and content cannot be defined for ${username} certificate!")
  }
  if $private_key and $private_key_content {
    fail("Both a source and content cannot be defined for ${username} private key!")
  }

  # Variable interpolation in class parameters can be goofy (PUP-1080)
  $homedir_real = pick($homedir,"/home/${username}")
  $sshkey_publickey_dir_real = pick($sshkey_publickey_dir,"${homedir_real}/.mcollective.d/credentials/public_keys")
  $sshkey_known_hosts_real = pick($sshkey_known_hosts,"${homedir_real}/.ssh/known_hosts")

  file { [
    "${homedir_real}/.mcollective.d",
    "${homedir_real}/.mcollective.d/credentials",
    "${homedir_real}/.mcollective.d/credentials/certs",
    "${homedir_real}/.mcollective.d/credentials/private_keys",
    "${homedir_real}/.mcollective.d/credentials/public_keys",
  ]:
    ensure => 'directory',
    owner  => $username,
    group  => $group,
  }

  datacat { "mcollective::user ${username}":
    path     => "${homedir_real}/.mcollective",
    collects => [ 'mcollective::user', 'mcollective::client' ],
    owner    => $username,
    group    => $group,
    mode     => '0400',
    template => 'mcollective/settings.cfg.erb',
  }

  if $_middleware_ssl or $_securityprovider == 'ssl' {
    file { "${homedir_real}/.mcollective.d/credentials/certs/ca.pem":
      ensure => 'file',
      source => $_ssl_ca_cert,
      owner  => $username,
      group  => $group,
      mode   => '0444',
    }

    file { "${homedir_real}/.mcollective.d/credentials/certs/server_public.pem":
      ensure => 'file',
      source => $_ssl_server_public,
      owner  => $username,
      group  => $group,
      mode   => '0444',
    }

    file { "${homedir_real}/.mcollective.d/credentials/private_keys/server_private.pem":
      ensure => 'file',
      source => $_ssl_server_private,
      owner  => $username,
      group  => $group,
      mode   => '0400',
    }
  }

  if $_securityprovider == 'ssl' or  $_securityprovider == 'sshkey' {
    $private_path = "${homedir_real}/.mcollective.d/credentials/private_keys/${callerid}.pem"
    if $private_key {
      file { $private_path:
        ensure => 'file',
        source =>  $private_key,
        owner  =>  $username,
        group  =>  $group,
        mode   =>  '0400',
      }
    }
    elsif $private_key_content {
      file { $private_path:
        ensure  => 'file',
        content => $private_key_content,
        owner   => $username,
        group   => $group,
        mode    => '0400',
      }
    }
    # Preserve old behavior
    elsif $_securityprovider == 'ssl' {
      file { $private_path:
        ensure => 'file',
        source =>  $_ssl_server_private,
        owner  =>  $username,
        group  =>  $group,
        mode   =>  '0400',
      }
    }
  }

  if $_securityprovider == 'ssl' {
    $cert_path = "${homedir_real}/.mcollective.d/credentials/certs/${callerid}.pem"
    if $certificate {
      file { $cert_path:
        ensure => 'file',
        source =>  $certificate,
        owner  =>  $username,
        group  =>  $group,
        mode   =>  '0444',
      }
    }
    elsif $certificate_content {
      file { $cert_path:
        ensure  => 'file',
        content =>  $certificate_content,
        owner   =>  $username,
        group   =>  $group,
        mode    =>  '0444',
      }
    }
    #preserve old behavior
    else {
      file { $cert_path:
        ensure => 'file',
        source =>  $ssl_server_public,
        owner  =>  $username,
        group  =>  $group,
        mode   =>  '0444',
      }
    }

    mcollective::user::setting { "${username}:plugin.ssl_client_public":
      setting  => 'plugin.ssl_client_public',
      username => $username,
      value    => "${homedir_real}/.mcollective.d/credentials/certs/${callerid}.pem",
      order    => '60',
    }

    mcollective::user::setting { "${username}:plugin.ssl_client_private":
      setting  => 'plugin.ssl_client_private',
      username => $username,
      value    => "${homedir_real}/.mcollective.d/credentials/private_keys/${callerid}.pem",
      order    => '60',
    }

    mcollective::user::setting { "${username}:plugin.ssl_server_public":
      setting  => 'plugin.ssl_server_public',
      username => $username,
      value    => "${homedir_real}/.mcollective.d/credentials/certs/server_public.pem",
      order    => '60',
    }
  }

  if $_securityprovider == 'sshkey' {
    $public_path = "${homedir_real}/.mcollective.d/credentials/public_keys/${callerid}.pem"
    if $public_key {
      file { $public_path:
        ensure => 'file',
        source => $public_key,
        owner  => $username,
        group  => $group,
        mode   => '0400',
      }
    }
    elsif $public_key_content {
      file { $public_path:
        ensure  => 'file',
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

    # Learning public keys implies you want to ignore known_hosts
    if $sshkey_learn_public_keys {
      mcollective::user::setting { "${username}:plugin.sshkey.client.publickey_dir":
        setting  => 'plugin.sshkey.client.publickey_dir',
        username => $username,
        value    => $sshkey_publickey_dir_real,
      }
    }
    else {
      mcollective::user::setting { "${username}:plugin.sshkey.client.known_hosts":
        setting  => 'plugin.sshkey.client.known_hosts',
        username => $username,
        value    => $sshkey_known_hosts_real,
      }
    }

    if $sshkey_enable_private_key {
      mcollective::user::setting { "${username}:plugin.sshkey.client.private_key":
        setting  => 'plugin.sshkey.client.private_key',
        username => $username,
        value    => $private_path,
      }
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
  if $_connector in [ 'activemq', 'rabbitmq' ] {
    $pool_size = size(flatten([$_middleware_hosts]))
    $hosts = range( '1', $pool_size )
    $connectors = prefix( $hosts, "${username}_" )
    mcollective::user::connector { $connectors:
      username       => $username,
      callerid       => $callerid,
      homedir        => $homedir_real,
      connector      => $_connector,
      middleware_ssl => $_middleware_ssl,
      ssl_ciphers    => $_ssl_ciphers,
      order          => '60',
    }
  }
}
