class site::activemq_broker (
  $activemq_memoryusage,
  $activemq_storeusage,
  $activemq_tempusage,
  $activemq_console = false,
  $activemq_confdir = '/etc/activemq',
) inherits site {

  class { '::activemq':
    instance      => 'mcollective',
    server_config => template('site/activemq_template.erb'),
  }

  contain 'activemq'

  File {
    require => Class['activemq::packages'],
    before  => Class['activemq::service'],
  }

  Java_ks {
    require => Class['activemq::packages'],
    before  => Class['activemq::service'],
  }

  file { "${activemq_confdir}/ca.pem":
    owner  => 'activemq',
    group  => 'activemq',
    mode   => '0444',
    source => $mcollective::ssl_ca_cert,
  }

  java_ks { 'mcollective:truststore':
    ensure       => 'latest',
    certificate  => "${activemq_confdir}/ca.pem",
    target       => "${activemq_confdir}/truststore.jks",
    password     => 'puppet',
    trustcacerts => true,
  }

  file { "${activemq_confdir}/truststore.jks":
    owner => 'activemq',
    group => 'activemq',
    mode  => '0400',
  }

  file { "${activemq_confdir}/server_public.pem":
    owner  => 'activemq',
    group  => 'activemq',
    mode   => '0444',
    source => $mcollective::ssl_server_public,
  }

  file { "${activemq_confdir}/server_private.pem":
    owner  => 'activemq',
    group  => 'activemq',
    mode   => '0400',
    source => $mcollective::ssl_server_private,
  }

  java_ks { 'mcollective:keystore':
    ensure       => 'latest',
    certificate  => "${activemq_confdir}/server_public.pem",
    private_key  => "${activemq_confdir}/server_private.pem",
    target       => "${activemq_confdir}/keystore.jks",
    password     => 'puppet',
    trustcacerts => true,
  }

  file { "${activemq_confdir}/keystore.jks":
    owner => 'activemq',
    group => 'activemq',
    mode  => '0400',
  }

}
