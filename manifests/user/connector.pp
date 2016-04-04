# private define
define mcollective::user::connector(
  $username,
  $callerid,
  $homedir,
  $order,
  $connector,
  $middleware_ssl,
  $ssl_ciphers,
) {
  $i = regsubst($title, "^${username}_", '')

  if $middleware_ssl {
    mcollective::user::setting { "${username} plugin.${connector}.pool.${i}.ssl.ca":
      setting  => "plugin.${connector}.pool.${i}.ssl.ca",
      username => $username,
      order    => $order,
      value    => "${homedir}/.mcollective.d/credentials/certs/ca.pem",
    }

    mcollective::user::setting { "${username} plugin.${connector}.pool.${i}.ssl.cert":
      setting  => "plugin.${connector}.pool.${i}.ssl.cert",
      username => $username,
      order    => $order,
      value    => "${homedir}/.mcollective.d/credentials/certs/${callerid}.pem",
    }

    mcollective::user::setting { "${username} plugin.${connector}.pool.${i}.ssl.key":
      setting  => "plugin.${connector}.pool.${i}.ssl.key",
      username => $username,
      order    => $order,
      value    => "${homedir}/.mcollective.d/credentials/private_keys/${callerid}.pem",
    }

    if ! empty( $ssl_ciphers ) {
      mcollective::user::setting { "${username} plugin.${connector}.pool.${i}.ssl.ciphers":
        setting  => "plugin.${connector}.pool.${i}.ssl.ciphers",
        username => $username,
        order    => $order,
        value    => $ssl_ciphers,
      }
    }
  }
}
