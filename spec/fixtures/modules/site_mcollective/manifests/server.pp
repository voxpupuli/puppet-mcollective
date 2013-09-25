#
class site_mcollective::server {
  mcollective::actionpolicy { 'rpcutil':
    default => 'deny',
  }

  mcollective::actionpolicy::rule { 'root rpcutil':
    agent    => 'rpcutil',
    callerid => 'cert=root',
  }
}
