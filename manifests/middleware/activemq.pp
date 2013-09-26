# private class
class mcollective::middleware::activemq {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $mcollective::activemq_config {
    $server_config = $mcollective::activemq_config
  }
  else {
    $server_config = template($mcollective::activemq_template)
  }

  anchor { 'mcollective::middleware::activemq::begin': } ->
  class { '::activemq':
    instance      => 'mcollective',
    server_config => $server_config,
  } ->
  anchor { 'mcollective::middleware::activemq::end': }

  if $mcollective::middleware_ssl {
    Class['activemq::packages'] ->

    file { "${mcollective::activemq_confdir}/ca.pem":
      owner  => 'activemq',
      group  => 'activemq',
      mode   => '0444',
      source => $mcollective::ssl_ca_cert,
    } ->

    java_ks { 'mcollective:truststore':
      ensure       => 'latest',
      certificate  => "${mcollective::activemq_confdir}/ca.pem",
      target       => "${mcollective::activemq_confdir}/truststore.jks",
      password     => 'puppet',
      trustcacerts => true,
    } ->

    file { "${mcollective::activemq_confdir}/truststore.jks":
      owner => 'activemq',
      group => 'activemq',
      mode  => '0400',
    } ->

    file { "${mcollective::activemq_confdir}/server_public.pem":
      owner  => 'activemq',
      group  => 'activemq',
      mode   => '0444',
      source => $mcollective::ssl_server_public,
    } ->

    file { "${mcollective::activemq_confdir}/server_private.pem":
      owner  => 'activemq',
      group  => 'activemq',
      mode   => '0400',
      source => $mcollective::ssl_server_private,
    } ->

    java_ks { 'mcollective:keystore':
      ensure       => 'latest',
      certificate  => "${mcollective::activemq_confdir}/server_public.pem",
      private_key  => "${mcollective::activemq_confdir}/server_private.pem",
      target       => "${mcollective::activemq_confdir}/keystore.jks",
      password     => 'puppet',
      trustcacerts => true,
    } ->

    file { "${mcollective::activemq_confdir}/keystore.jks":
      owner => 'activemq',
      group => 'activemq',
      mode  => '0400',
    } ->

    Class['activemq::service']
  }
}
