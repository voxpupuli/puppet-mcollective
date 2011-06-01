# Class: mcollective::server::service
#
#   This class installs and enables the MCollective service.
#
# Parameters:
#
#  [*mc_service_name*]  - The name of the mcollective service
#  [*mc_service_stop*]  - The command used to stop the mcollective service
#  [*mc_service_start*] - The command used to start the mcollective service
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
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
