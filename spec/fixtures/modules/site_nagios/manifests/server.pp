#
class site_nagios::server {
  user { 'nagios':
    ensure     => 'present',
    managehome => true,
  } ->
  # XXX This is referring to keys from outside our module - how to hide?
  mcollective::user { 'nagios':
    certificate => 'puppet:///modules/site_mcollective/certs/nagios.pem',
    private_key => 'puppet:///modules/site_mcollective/private_keys/nagios.pem',
  }
}
