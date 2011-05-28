class mcollective::client::base(
  $version,
  $config,
  $config_file,
  $pkg_provider = $mcollective::params::pkg_provider
) inherits mcollective::params {

  class { 'mcollective::client::config':
    config      => $config,
    config_file => $config_file,
  }
  class { 'mcollective::client::pkg':
    version      => $version,
    pkg_provider => $pkg_provider,
    require      => Class['mcollective::client::config'],
  }

}
