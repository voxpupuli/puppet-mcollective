# private define
# $name will be an index into the $mcollective::middleware_hostsarray + 1
define mcollective::common::config::connector::activemq::hosts_iteration {
  $middleware_hosts_array = flatten([$mcollective::middleware_hosts])
  mcollective::common::setting { "plugin.activemq.pool.${name}.host":
    value => $middleware_hosts_array[$name - 1],
  }

  $port = $mcollective::middleware_ssl ? {
    true    => $mcollective::middleware_ssl_port,
    default => $mcollective::middleware_port,
  }

  $fallback = $mcollective::middleware_ssl_fallback ? {
    true    => 1,
    default => 0,
  }

  mcollective::common::setting { "plugin.activemq.pool.${name}.port":
    value => $port,
  }

  mcollective::common::setting { "plugin.activemq.pool.${name}.user":
    value => $mcollective::middleware_user,
  }

  mcollective::common::setting { "plugin.activemq.pool.${name}.password":
    value => $mcollective::middleware_password,
  }

  if $mcollective::middleware_ssl {
    mcollective::common::setting { "plugin.activemq.pool.${name}.ssl":
      value => 1,
    }

    mcollective::common::setting { "plugin.activemq.pool.${name}.ssl.ca":
      value => "${mcollective::confdir}/ca.pem",
    }

    mcollective::common::setting { "plugin.activemq.pool.${name}.ssl.fallback":
      value => $fallback,
    }
  }
}
