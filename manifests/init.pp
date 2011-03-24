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
  $version = 'UNSET',
  $config  = 'UNSET'
) inherits mcollective::params {

  ## Input Validation

  if $version == 'UNSET' {
    $version_real = 'present'
  } else {
    $version_real = $version
  }

  # JJM The configuration should be last in case variables are interpolated in
  # the template shipped with this module.
  if $config == 'UNSET' {
    $config_real = template("${module_name}/server.cfg")
  } else {
    $config_real = $config
  }

  ## Resource Declarations

  package { 'mcollective':
    ensure => $version_real,
  }

  file { '/etc/mcollective/server.cfg':
    ensure  => file,
    owner   => '0',
    group   => '0',
    mode    => '0640',
    content => $config_real,
    require => Package['mcollective'],
    notify  => Class['mcollective::service'],
  }

}

