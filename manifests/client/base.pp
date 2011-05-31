class mcollective::client::base(
  $version,
  $config,
  $config_file
) inherits mcollective::params {

  class { 'mcollective::client::package':
    version      => $version,
  }
  class { 'mcollective::client::config':
    config      => $config,
    config_file => $config_file,
    require     => Class['mcollective::client::package'],
  }

}

