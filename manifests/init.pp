# Class: mcollective
#
#   This class manages the MCollective server packages and configuration.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#  class { 'mcollective':
#    version => '1.0.1',
#    config  => template('site_data/mcollective/server.cfg')
#  }
#
# [Remember: No empty lines between comments and class definition]
class mcollective(
  $version       = 'UNSET',
  $server        = true,
  $server_config = 'UNSET',
  $client        = true,
  $client_config = 'UNSET'
) inherits mcollective::params {

  ## Input Validation

  $v_bool = [ '^true$', '^false$' ]
  validate_re("$server", $v_bool)
  validate_re("$client", $v_bool)
  $server_real = $server
  $client_real = $client

  if $version == 'UNSET' {
    $version_real = 'present'
  } else {
    $version_real = $version
  }

  # JJM The configuration should be last in case variables are interpolated in
  # the template shipped with this module.
  if $server_config == 'UNSET' {
    $server_config_real = template("${module_name}/server.cfg")
  } else {
    $server_config_real = $config
  }
  if $client_config == 'UNSET' {
    $client_config_real = template("${module_name}/client.cfg")
  } else {
    $client_config_real = $config
  }

  ## Resource Declarations

  mcollective::pkg { 'mcollective-common':
    version => $version_real,
    ensure  => present,
  }

  if $server_real {
    # Manage the package
    mcollective::pkg { 'mcollective':
      ensure  => present,
      version => $version_real,
      require => Mcollective::Pkg['mcollective-common'],
    }
    # Manage the configuration file
    file { '/etc/mcollective/server.cfg':
      ensure  => file,
      owner   => '0',
      group   => '0',
      mode    => '0640',
      content => $config_real,
      require => Mcollective::Pkg['mcollective'],
      notify  => Class['mcollective::service'],
    }
    # Manage the service
    class { 'mcollective::service':
      stage => 'deploy_infra',
    }
  }

  if $client_real {
    # Manage the package
    mcollective::pkg { 'mcollective-client':
      ensure  => present,
      version => $version_real,
      require => Mcollective::Pkg['mcollective-common'],
    }
    # Manage the configuration file
    file { '/etc/mcollective/client.cfg':
      ensure  => file,
      owner   => '0',
      group   => '0',
      mode    => '0640',
      content => $config_real,
      require => Mcollective::Pkg['mcollective-client'],
    }
  }


}

