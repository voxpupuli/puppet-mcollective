# private define
define mcollective::user::connector($username, $homedir, $order, $connector, $middleware_ssl) {
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
      value    => "${homedir}/.mcollective.d/credentials/certs/${username}.pem",
    }

    mcollective::user::setting { "${username} plugin.${connector}.pool.${i}.ssl.key":
      setting  => "plugin.${connector}.pool.${i}.ssl.key",
      username => $username,
      order    => $order,
      value    => "${homedir}/.mcollective.d/credentials/private_keys/${username}.pem",
    }
  }
}
