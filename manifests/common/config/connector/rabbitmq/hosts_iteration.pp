# private define
# $name will be an index into the $mcollective::middleware_hosts array + 1
define mcollective::common::config::connector::rabbitmq::hosts_iteration {
  mcollective::common::setting { "plugin.rabbitmq.pool.${name}.host":
    value => $mcollective::middleware_hosts[$name - 1], # puppet array 0-based
  }

  $middleware_ssl = str2bool($mcollective::middleware_ssl)

  $port = $middleware_ssl ? {
    true    => $mcollective::middleware_ssl_port,
    default => $mcollective::middleware_port,
  }

  $fallback = $mcollective::middleware_ssl_fallback ? {
    true    => 1,
    default => 0,
  }

  mcollective::common::setting { "plugin.rabbitmq.pool.${name}.port":
    value => $port,
  }

  mcollective::common::setting { "plugin.rabbitmq.pool.${name}.user":
    value => $mcollective::middleware_user,
  }

  mcollective::common::setting { "plugin.rabbitmq.pool.${name}.password":
    value => $mcollective::middleware_password,
  }

  if $middleware_ssl {
    mcollective::common::setting { "plugin.rabbitmq.pool.${name}.ssl":
      value => 1,
    }

    mcollective::common::setting { "plugin.rabbitmq.pool.${name}.ssl.ca":
      value => $::mcollective::middleware_ssl_ca_path,
    }

    mcollective::common::setting { "plugin.rabbitmq.pool.${name}.ssl.fallback":
      value => $fallback,
    }
  }
}
