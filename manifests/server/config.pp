class mcollective::server::config(
  $config_file,
  $config,
  $server_config_owner   = $mcollective::params::server_config_owner,
  $server_config_group   = $mcollective::params::server_config_group
) inherits mcollective::params {

  file { 'server_config':
    path    => $config_file,
    content => $config,
    mode    => '0600',
    owner   => $server_config_owner,
    group   => $server_config_group,
    require => Class['mcollective::server::pkg'],
  }

}
