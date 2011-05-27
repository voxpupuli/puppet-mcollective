class mcollective::server::base(
  $version,
  $config,
  $config_file,
  $pkg_provider  = $mcollective::params::pkg_provider
) inherits mcollective::params {

  class { 'mcollective::server::config':
    config       => $config,
    config_file  => $config_file,
    stage        => main,
  }
  class { 'mcollective::server::pkg':
    version      => $version,
    pkg_provider => $pkg_provider,
    stage        => setup_infra,
  }
  class { 'mcollective::server::service':
    stage        => deploy_app,
  }

}
