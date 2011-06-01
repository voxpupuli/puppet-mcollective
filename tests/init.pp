node default {

  # The default behavior is to configure the server only and not the client.
  # The following PSK and Server settings are the defaults, but you may
  # want to change them for your site.
  class { 'mcollective':
    mc_security_psk => 'changemeplease',
    stomp_server    => 'stomp',
  }

}
