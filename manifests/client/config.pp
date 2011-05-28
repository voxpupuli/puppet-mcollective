class mcollective::client::config(
  $config_file,
  $config,
  $client_config_owner   = $mcollective::params::client_config_owner,
  $client_config_group   = $mcollective::params::client_config_group
) inherits mcollective::params {

  file { 'client_config':
    path    => $config_file,
    content => $config,
    mode    => '0600',
    owner   => $client_config_owner,
    group   => $client_config_group,
  }

}
