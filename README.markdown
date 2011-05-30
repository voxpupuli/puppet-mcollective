# MCollective Module

Jeff McCune <jeff@puppetlabs.com>

This module manages MCollective from within Puppet.

# Quick Start

Manage both the mcollective server and client.  Connect to the stomp server
named "stomp."

    node default {
      class { 'mcollective': }
    }

Change the pre-shared key for both the client and the server:

    node default {
      class { 'mcollective':
        mc_security_psk => 'abc123',
      }
    }

# Registration #

MCollective servers will automatically register themselves with the default
behavior of this module.  For more information about registration please see:

 * [MCollective
   Registration](http://docs.puppetlabs.com/mcollective/reference/plugins/registration.html)
 * [RIP's Blog on
   Registration](http://www.devco.net/archives/2009/11/15/registration_in_mcollective.php)

The out of box behavior is for _all_ nodes to deploy a simple agent named
'registration' that writes information about the registering node to
/var/tmp/mcollective  This agent may be disabled to prevent all nodes from
filling up their disks, but this is only an issue for extremely large sites.
