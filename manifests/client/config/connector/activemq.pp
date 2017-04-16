# private class
class mcollective::client::config::connector::activemq {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # handle the case that activemq connection is ssl encrypted and psk secured
  if $mcollective::middleware_ssl and $mcollective::securityprovider == "psk" {
    
    mcollective::client::setting { "plugin.activemq.pool.1.ssl.cert":
      value => '/etc/mcollective/server_public.pem',
    }
    
    mcollective::client::setting { "plugin.activemq.pool.1.ssl.key":
      value => '/etc/mcollective/server_private.pem',
    }
    
  }
}