class mcollective::server::service(
  $mc_service_name     = $mcollective::params::mc_service_name,
  $mc_service_stop     = $mcollective::params::mc_service_stop,
  $mc_service_start    = $mcollective::params::mc_service_start
) {

  service { $mc_service_name:
    ensure     => running,
    enable     => false,
    hasstatus  => true,
    start      => $mc_service_start,
    stop       => $mc_service_stop,
    subscribe  => Class['mcollective'],
  }

}
