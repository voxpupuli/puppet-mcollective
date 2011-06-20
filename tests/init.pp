node default {

  # The default behavior is to configure the server only and not the client.
  # The following PSK and Server settings are the defaults, but you may
  # want to change them for your site.
  notify { "alpha":
    message => "alpha",
  }
  ->
  class { 'java': }
  ->
  class { 'activemq': }
  ->
  class { 'mcollective':
    mc_security_psk => 'changemeplease',
    stomp_server    => 'stomp',
    server          => true,
    client          => true,
  }
  ->
  notify { "omega":
    message => "omega",
  }

}
