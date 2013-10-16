# private define
# $name will be an index into the $mcollective::middleware_hosts array + 1
define mcollective::server::config::connector::activemq::hosts_iteration {
  if $mcollective::middleware_ssl {
    if $mcollective::server_use_agent_ssl {
      $cert = $mcollective::server_ssl_cert
      $key  = $mcollective::server_ssl_key
    }
    else {
      $cert = '/etc/mcollective/server_public.pem'
      $key  = '/etc/mcollective/server_private.pem'
    }
    mcollective::server::setting { "plugin.activemq.pool.${name}.ssl.cert":
      value => $cert,
    }

    mcollective::server::setting { "plugin.activemq.pool.${name}.ssl.key":
      value => $key,
    }
  }
}
