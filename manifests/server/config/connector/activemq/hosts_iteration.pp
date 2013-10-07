# private define
# $name will be an index into the $mcollective::middleware_hosts array + 1
define mcollective::server::config::connector::activemq::hosts_iteration {
  if $mcollective::middleware_ssl {
    mcollective::server::setting { "plugin.activemq.pool.${name}.ssl.cert":
      value => $mcollective::server_ssl_cert,
    }

    mcollective::server::setting { "plugin.activemq.pool.${name}.ssl.key":
      value => $mcollective::server_ssl_key,
    }
  }
}
