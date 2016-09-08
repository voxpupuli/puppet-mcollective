# This class prepares an ActiveMQ middleware service for use by MCollective.
#
# The default parameters come from the mco_profile::params class for only one
# reason. It allows the user to OPTIONALLY use Hiera to set values in one place
# and have them propagate multiple related classes. This will only work if the
# parameters are set in Hiera. It will not work if the parameters are set from
# an ENC.
#
class mco_profile::middleware::activemq (
  $memoryusage               = '200 mb',
  $storeusage                = '1 gb',
  $tempusage                 = '1 gb',
  $console                   = false,
  $ssl_ca_cert               = $mco_profile::params::ssl_ca_cert,
  $ssl_server_cert           = $mco_profile::params::ssl_server_cert,
  $ssl_server_private        = $mco_profile::params::ssl_server_private,
  $middleware_user           = $mco_profile::params::middleware_user,
  $middleware_password       = $mco_profile::params::middleware_password,
  $middleware_admin_user     = $mco_profile::params::middleware_admin_user,
  $middleware_admin_password = $mco_profile::params::middleware_admin_password,
  $middleware_ssl_port       = $mco_profile::params::middleware_ssl_port,
) inherits mco_profile::params {

  # We need to know somewhat for sure exactly what configuration directory
  # will be used for ActiveMQ in order to correctly build the template.
  $confdir = $::osfamily ? {
    'Debian' => '/etc/activemq/instances-available/mcollective',
    default  => '/etc/activemq',
  }

  # Set up and contain the ActiveMQ server using the puppetlabs/activemq
  # module
  class { '::activemq':
    instance      => 'mcollective',
    server_config => template('mco_profile/activemq_template.erb'),
  }
  contain '::activemq'

  # Set up SSL configuration. Use copies of the PEM keys specified to create
  # the Java keystores.
  file { "${confdir}/ca.pem":
    owner   => 'activemq',
    group   => 'activemq',
    mode    => '0444',
    source  => $ssl_ca_cert,
    require => Class['activemq::packages'],
  }
  file { "${confdir}/server_cert.pem":
    owner   => 'activemq',
    group   => 'activemq',
    mode    => '0444',
    source  => $ssl_server_cert,
    require => Class['activemq::packages'],
  }
  file { "${confdir}/server_private.pem":
    owner   => 'activemq',
    group   => 'activemq',
    mode    => '0400',
    source  => $ssl_server_private,
    require => Class['activemq::packages'],
  }

  java_ks { 'mcollective:truststore':
    ensure       => 'latest',
    certificate  => "${confdir}/ca.pem",
    target       => "${confdir}/truststore.jks",
    password     => 'puppet',
    trustcacerts => true,
    notify       => Class['activemq::service'],
    require      => File["${confdir}/ca.pem"],
  } ->

  file { "${confdir}/truststore.jks":
    owner   => 'activemq',
    group   => 'activemq',
    mode    => '0400',
    require => Class['activemq::packages'],
    before  => Java_ks['mcollective:keystore'],
  }

  java_ks { 'mcollective:keystore':
    ensure       => 'latest',
    certificate  => "${confdir}/server_cert.pem",
    private_key  => "${confdir}/server_private.pem",
    target       => "${confdir}/keystore.jks",
    password     => 'puppet',
    trustcacerts => true,
    before       => Class['activemq::service'],
    require      => [
      File["${confdir}/server_cert.pem"],
      File["${confdir}/server_private.pem"],
    ],
  } ->
  file { "${confdir}/keystore.jks":
    owner   => 'activemq',
    group   => 'activemq',
    mode    => '0400',
    require => Class['activemq::packages'],
    before  => Class['activemq::service'],
  }

}
