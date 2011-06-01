node default {

  # Setup the MCollective client and server to talk to the Middleware at
  # stomp.puppetlabs.lan The default security provider of 'psk' will be used.
  # (Note, the client packages default to "false" while the server
  # configuration defaults to "true")
  class { 'mcollective':
    stomp_server         => 'stomp.puppetlabs.lan'
    server               => true,
    client               => true,
    mc_security_provider => 'psk',
    mc_security_psk      => 'abc123',
  }

}
