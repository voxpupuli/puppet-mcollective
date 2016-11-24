# MCollective module for Puppet

[![Build Status](https://travis-ci.org/voxpupuli/puppet-mcollective.png?branch=master)](https://travis-ci.org/voxpupuli/puppet-mcollective)
[![Code Coverage](https://coveralls.io/repos/github/voxpupuli/puppet-mcollective/badge.svg?branch=master)](https://coveralls.io/github/voxpupuli/puppet-mcollective)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/mcollective.svg)](https://forge.puppetlabs.com/puppet/mcollective)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/mcollective.svg)](https://forge.puppetlabs.com/puppet/mcollective)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/mcollective.svg)](https://forge.puppetlabs.com/puppet/mcollective)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/mcollective.svg)](https://forge.puppetlabs.com/puppet/mcollective)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with mcollective](#setup)
    * [What the mcollective module affects](#what-the-mcollective-module-affects)
    * [Beginning with mcollective](#beginning-with-mcollective)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

The mcollective module installs, configures, and manages the mcollective
agents, and clients of an MCollective cluster.

## Module Description

The mcollective module handles installing and configuring mcollective across a
range of operating systems and distributions.  Where possible we follow the
standards laid down by the
[MCollective Standard Deployment guide](http://docs.puppetlabs.com/mcollective/deploy/standard.html).

### MCollective Terminology

A quick aside, mcollective's terminology differs a little from what you might
be used to in puppet.  There are 3 main components, the client (the mco
commands you run to control your servers), the server (a daemon that runs on
all of your managed nodes and executes the commands), and the middleware (a
message broker the servers and agent connect to).

If it helps to map these to puppet concepts you loosely have:

* Middleware -> Puppet Master
* MCollective Server -> Puppet Agent
* MCollective Client -> no direct equivalent

## Setup

### What the mcollective module affects

On a server

* mcollective package
* mcollective server configuration file
* mcollective service

On a client

* mcollective-client package
* mcollective client configuration file
* optionally user configuration files (~/.mcollective and ~/.mcollective.d)

### Beginning with mcollective

Your main entrypoint to the mcollective module is the mcollective class, so
assuming you have your middleware configured on a node this is all you need to
add a server to mcollective.

```puppet
class { '::mcollective':
  middleware_hosts => [ 'broker1.example.com' ],
}
```

## Usage

Your primary interaction with the mcollective module will be though the main
mcollective class, with secondary configuration managed by the defined types
`mcollective::user`, `mcollective::plugin`, `mcollective::actionpolicy`, and
`mcollective::actionpolicy::rule`.

### I just want to run it, what's the minimum I need?

```puppet
node 'broker1.example.com' {
  include activemq
}

node 'server1.example.com' {
  class { '::mcollective':
    middleware_hosts => [ 'broker1.example.com' ],
  }
}

node 'control1.example.com' {
  class { '::mcollective':
    client            => true,
    middleware_hosts => [ 'broker1.example.com' ],
  }
}
```

This default install will be using *no* TLS, a set of well-known usernames and
passwords, and the psk securityprovider.  This is against the recommendataion
of the standard deploy guide but does save you from having to deal with ssl
certificates to begin with.

### I'd like to secure the transport channel and authenticate users, how do I do that?

Gather some credentials for the server and users.  You'll need the ca
certificate, and a keypair for the server to use, and a keypair for each user
to allow.

See the [standard deploy guide](http://docs.puppetlabs.com/mcollective/deploy/standard.html#step-1-create-and-collect-credentials)
for more information about how to generate these.

```puppet
node 'broker1.example.com' {
  # Please see
  # https://github.com/voxpupuli/puppet-mcollective/blob/master/examples/ssl_example/mco_profile/manifests/middleware/activemq.pp
  # for this as setting up activemq with a truststore can be quite complex.
}

node 'server1.example.com' {
  class { '::mcollective':
    middleware_hosts    => [ 'broker1.example.com' ],
    middleware_ssl      => true,
    middleware_ssl_cert => "/var/lib/puppet/ssl/certs/${::clientcert}.pem",
    middleware_ssl_key  => "/var/lib/puppet/ssl/private_keys/${::clientcert}.pem",
    middleware_ssl_ca   => "/var/lib/puppet/ssl/certs/ca.pem",
    securityprovider    => 'ssl',
    ssl_client_certs    => 'puppet:///modules/site_mcollective/client_certs',
    ssl_ca_cert         => 'puppet:///modules/site_mcollective/certs/ca.pem',
    ssl_server_public   => 'puppet:///modules/site_mcollective/certs/server.pem',
    ssl_server_private  => 'puppet:///modules/site_mcollective/private_keys/server.pem',
  }

  mcollective::actionpolicy { 'nrpe':
    default => 'deny',
  }

  mcollective::actionpolicy::rule { 'vagrant user can use nrpe agent':
    agent    => 'nrpe',
    callerid => 'cert=vagrant',
  }
}

node 'control.example.com' {
  class { '::mcollective':
    client              => true,
    middleware_hosts    => [ 'broker1.example.com' ],
    middleware_ssl      => true,
    middleware_ssl_cert => "/var/lib/puppet/ssl/certs/${::clientcert}.pem",
    middleware_ssl_key  => "/var/lib/puppet/ssl/private_keys/${::clientcert}.pem",
    middleware_ssl_ca   => "/var/lib/puppet/ssl/certs/ca.pem",
    securityprovider    => 'ssl',
    ssl_client_certs    => 'puppet:///modules/site_mcollective/client_certs',
    ssl_ca_cert         => 'puppet:///modules/site_mcollective/certs/ca.pem',
    ssl_server_public   => 'puppet:///modules/site_mcollective/certs/server.pem',
    ssl_server_private  => 'puppet:///modules/site_mcollective/private_keys/server.pem',
  }

  mcollective::user { 'vagrant':
    certificate => 'puppet:///modules/site_mcollective/client_certs/vagrant.pem',
    private_key => 'puppet:///modules/site_mcollective/private_keys/vagrant.pem',
  }
}
```

### I'd like to secure the transport channel and authenticate users with just their private key, how do I do that?

The Mcollective standard deployment guide uses the 'ssl' securityprovider to handle
authentication.  If you're interested in performing the authentication without
creating SSL certificates for each user, one alternative is to use the 'sshkey'
securityprovider.  As far as the transport channel encryption goes, it's no different
than the above example's use of 'middleware_ssl*' parameters.

Sshkey adds additional flexibility with regards to deployment as it currently supports
both a static and a dynamic key management philosophy.  You can seperate sshkey from
your normal system authentication's backend (known\_hosts / authorized\_keys) and
permit it to send and record its key data for you.  If you do this, you should strongly
consider using an authorization plugin with mcollective. Alternatively, you can use
puppet to enforce the available set of key data to use with requests and responses.
Because this could reuse an existing user's ssh private key, it could work along-side
your existing user management module.

The use of sshkey is optional.  For further information, you can review a sample
deployment in the /examples folder, review the [sshkey module documentation](https://github.com/puppetlabs/mcollective-sshkey-security),
and review the [sshkeyauth rubygem documentation](https://github.com/jordansissel/ruby-sshkeyauth)
(helpful for debugging errors).

### The `::mcollective::` class

The `mcollective` class is the main entry point to the module.  From here you
can configure the behaviour of your mcollective install of server, client, and
middleware.

#### Parameters

The following parameters are available to the mcollective class:

##### `server`

Boolean: defaults to true.  Whether to install the mcollective server on this
node.

##### `client`

Boolean: defaults to false.  Whether to install the mcollective client
application on this node.

##### `rabbitmq_vhost`

String: defaults to '/mcollective'.  The vhost to connect to/manage when using
rabbitmq middleware.

##### `manage_packages`

Boolean: defaults to true.  Whether to install mcollective and mcollective-
client packages when installing the server and client components.

##### `version`

String: defaults to 'present'.  What version of packages to `ensure` when
`mcollective::manage_packages` is true.

##### `client_package`

String: defaults to 'mcollective-client'. The name of the package to install for
the client part. In the case that there is only one package package handling both,
client and server, give the same name for 'client_package' and 'server_package'.

##### `server_package`

String: defaults to 'mcollective'. The name of the package to install for
the server. In the case that there is only one package package handling both,
client and server, give the same name for 'client_package' and 'server_package'.

##### `ruby_stomp_ensure`

String: defaults to 'installed'.  What version of the ruby-stomp package to
`ensure` when `mcollective::manage_packages` is true. Only relevant on the
Debian OS family.

##### `main_collective`

String: defaults to 'mcollective'.  The name of the main collective for this
client/server.

##### `collectives`

String: defaults to 'mcollective'.  Comma seperated list of collectives this
server should join.

##### `connector`

String: defaults to 'activemq'.  Name of the connector plugin to use.

Currently supported are `activemq`, `rabbitmq`, and `redis`

##### `securityprovider`

String: defaults to 'psk'.  Name of the security provider plugin to use.
'ssl' is recommended but requires some additional setup.

##### `psk`

String: defaults to 'changemeplease'.  Used by the 'psk' security provider as
the pre-shared key to secure the collective with.

##### `factsource`

String: defaults to 'yaml'.  Name of the factsource plugin to use on the
server.

##### `fact_cron_splay`
Boolean: defaults to false. Spread the cron tasks so that not all the nodes
runs the facter cronjob at the exact same time.

##### `yaml_fact_path`

String: defaults to '/etc/mcollective/facts.yaml'.  Name of the file the
'yaml' factsource plugin should load facts from.

##### `ruby_interpreter`

String: defaults to '/usr/bin/env ruby' for non PE installations, and to
'/opt/puppet/bin/ruby' for PE installations. With `factsource` 'yaml', a ruby
script is installed as cron job, which needs to find the ruby interpreter.
This parameter allows overriding the default interpreter.

##### `classesfile`

String: defaults to '/var/lib/puppet/state/classes.txt'.  Name of the file the
server will load the configuration management class for filtering.

##### `rpcauthprovider`

String: defaults to 'action_policy'.  Name of the RPC Auth Provider to use on
the server.

##### `rpcauditprovider`

String: defaults to 'logfile'.  Name of the RPC Audit Provider to use on the
server.

##### `rpcauditlogfile`

String: defaults to '/var/log/mcollective-audit.log'.  Name of the audit
logfile.

##### `registration`

String: defaults to undef.  Name of the registration plugin to use on the
server.

##### `core_libdir`

String: default is based on platform.  Path to the core plugins that are
installed by the mcollective-common package.

##### `site_libdir`

String: default is based on platform.  Path to the site-specific plugins that
the `mcollective::plugin` type will install with its `source` parameter.

This path will be managed and purged by puppet, so don't point it at
core_libdir or any other non-dedicated path.

##### `middleware_hosts`

Array of strings: defaults to [].  Where the middleware servers this
client/server should talk to are.

##### `middleware_user`

String: defaults to 'mcollective'. Username to use when connecting to the
middleware.

##### `middleware_password`

String: defaults to 'marionette'.  Password to use when connecting to the
middleware.

##### `middleware_port`

String: defaults to '61613' (for `activemq`).  Port number to use when
connecting to the middleware over an unencrypted connection.

##### `middleware_ssl_port`

String: defaults to '61614'. Port number to use when connecting to the
middleware over a ssl connection.

##### `middleware_ssl`

Boolean: defaults to false.  Whether to talk to the middleware over a ssl
protected channel.  Highly recommended.  Requires `mcollective::ssl_ca_cert`,
`mcollective::ssl_server_public`, `mcollective::ssl_server_private` parameters
for the server/client install.

##### `middleware_admin_user`

String: defaults to 'admin'.  Username for the middleware admin user.

##### `middleware_admin_password`

String: defaults to 'secret'.  Password to for the middleware
admin user.

##### `server_config_file`

String: default is '$confdir/server.cfg'.  Path to the server
configuration file.

##### `server_logfile`

String: defaults to '/var/log/mcollective.log'.  Logfile the mcollective
server should log to.

##### `server_loglevel`

String: defaults to 'info'.  Level the mcollective server should log at.

##### `server_daemonize`

Boolean: defaults to true.  Should the mcollective server daemonize when
started.

##### `client_config_file`

String: defaults to '$confdir/client.cfg'.  Path to the client
configuration file.

##### `client_logger_type`

String: defaults to 'console'.  What type of logger the client should use.

##### `client_loglevel`

String: defaults to 'warn'.  Level the mcollective client should log at.

##### `ssl_ca_cert`

String: defaults to undef.  A file source that points to the ca certificate
used to manage the ssl keys of the mcollective install.

##### `ssl_server_public`

String: defaults to undef.  A file source that points to the public key or
certificate of the server keypair.

##### `ssl_server_private`

String: defaults to undef.  A file source that points to the private key of
the server keypair.

##### `ssl_client_certs`

String: defaults to 'puppet:///modules/mcollective/empty'.  A file source that
contains a directory of user certificates which are used by the ssl security
provider in authenticating user requests.

##### `sshkey_server_learn_public_keys`

Boolean: defaults to false.  Allow writing sshkey public keys to
`sshkey_server_publickey_dir`.

##### `sshkey_server_overwrite_stored_keys`

Boolean: defaults to false.  Overwrite learned keys.

##### `sshkey_server_publickey_dir`

String: defaults to `${confdir}/sshkey_pubdir`.  Directory to store
received keys

##### `sshkey_server_private_key`

String: defaults to '/etc/ssh/ssh\_host\_rsa\_key'.  The private key used to
sign replies with.

##### `sshkey_server_authorized_keys`

String: defaults to undefined.  The authorized_key file to use.  Undefined
is interpreted by sshkey to mean the caller's authorized key file.

##### `sshkey_server_send_key`

String: defaults to undefined.  Specifies the public key
sent back with the response for validation. You probably want
'/etc/ssh/ssh\_host\_rsa\_key.pub'.

### `mcollective::user` defined type

`mcollective::user` installs a client configuration and any needed client
certificates in a users home directory.

#### Parameters

##### `username`

String: defaults to $name. The username of the user to install for.

##### `group`

String: defaults to $name. The group of the user to install for.

##### `homedir`

String: defaults to "/home/${name}".  The home directory of the user to
install for.

##### `certificate`

String: defaults to undef.  A file source for the certificate of the user.
Used by the 'ssl' securityprovider to set the identity of the user. This is
mutually exclusive with `certificate_content`.

##### `certificate_content`

String: defaults to undef.  The file content for the certificate of the user.
Used by the 'ssl' securityprovider to set the identity of the user. This is
mutually exclusive with `certificate`.

##### `private_key`

String: defaults to undef.  A file source for the private key of the user.
Used by the 'ssl' & 'sshkey' securityprovider to sign messages as from this user.
When not supplied to sshkey, this is interpreted to use the user's ssh-agent.
This is mutually exclusive with `private_key_content`.

##### `private_key_content`

String: defaults to undef.  The file content for the private key of the user.
Used by the 'ssl' & 'sshkey' securityprovider to sign messages as from this user.
This is mutually exclusive with `private_key`.

##### `sshkey_learn_public_keys`

Boolean: defaults to false.  Allow writing sshkey public keys to
`sshkey_client_publickey_dir`.

##### `sshkey_overwrite_stored_keys`

Boolean: defaults to false.  Overwrite learned keys.

##### `sshkey_publickey_dir`

String: defaults to `${homedir}/.mcollective.d/public_keys`.  Directory to store
received keys.

##### `sshkey_enable_private_key`

Boolean: defaults to false.  Enable manual specification of the private key to
sign requests with.  False is interpreted by sshkey to use the
user's ssh-agent.

##### `sshkey_known_hosts`

String: defaults to '${homedir}/${callerid}/.ssh/known\_hosts'. The known\_hosts
file to use.  This is mutually exclusive with `sshkey_publickey_dir` and is disabled
by `sshkey_learn_public_keys`.

##### `sshkey_enable_send_key`

Boolean: defaults to false.  Enable sending the user public key inside the
request.

### `mcollective::plugin` defined type

`mcollective::plugin` installs a plugin from a source uri or a package.  When
installing from a source uri the plugin will be copied to
`mcollective::site_libdir`

```puppet
mcollective::plugin { 'puppet':
  package => true,
}
```

When installing a plugin from source you need to create the correct directory
structure for it to work.

For example if you wish to sync an agent for apt which ships with ``apt.ddl``
and ``apt.rb`` you need to create the following structure:

```
site_mcollective/files/plugins/apt/
                               └── mcollective
                                   └── agent
                                       ├── apt.ddl
                                       └── apt.rb
```

Now you can then point the ``source`` attribute of the defined type to the
apt folder in your plugins directory.

```puppet
mcollective::plugin { 'apt':
  source => 'puppet:///modules/site_mcollective/plugins/apt',
}
```

For more examples have a look at the directory structure in ``files/plugins``
of this module.

#### Parameters

##### `name`

String: the resource title.  The base name of the plugin to install.

##### `source`

String: will default to "puppet:///modules/mcollective/plugins/${name}".  The
source uri that will be copied to `mcollective::site_libdir`

##### `package`

Boolean: defaults to false.  Whether to install the plugin from a file copy or
a package install.

##### `type`

String: defaults to 'agent'.  The type of the plugin package to install.

##### `has_client`

Boolean: defaults to true.  When installing from a package, whether to attempt
to install `mcollective-${name}-client` on the client node.

### `mcollective::actionpolicy` defined type

`mcollective::actionpolicy` configures an agent for use with actionpolicy in
conjunction with `mcollective::actionpolicy::rule`.

#### Parameters

##### `name`

String: the resource title.  The name of the agent to set up an actionpolicy
for.

##### `default`

String: defaults to 'deny'.  The default actionpolicy to apply to the agent.

### `mcollective::actionpolicy::rule` defined type

`mcollective::actionpolicy::rule` represents a single actionpolicy policy
entry. See the actionpolicy plugin [Policy File Format](https://github.com/puppetlabs/mcollective-actionpolicy-auth#policy-file-format)
for specific restrictions on the values of these fields.

#### Parameters

##### `name`

String: the resource title.  A descriptive name for the rule you are adding.

##### `agent`

String: required, no default.  The name of the agent you are adding a rule
for.

##### `action`

String: defaults to 'allow'.  What to do when the other conditions of this
line are matched.

##### `callerid`

String: defaults to '*'.  What callerids should match this rule.

##### `actions`

String: defaults to '*'.  What actions should match this rule.

##### `fact_filter`

String: defaults to '*'.  What facts should match this rule. This can be either
'*', a space-separated list of ``fact=value`` pairs (which match if every listed
fact matches), or any valid [compound filter string](http://docs.puppetlabs.com/mcollective/reference/basic/basic_cli_usage.html#complex-compound-or-select-queries).
This matches the "facts" field of the policy file lines.

##### `classes`

String: defaults to '*'.  What classes should match this rule.

### `mcollective::common::setting` defined type

`mcollective::common::setting` declares a setting that is common between
server and client.

#### Parameters

##### `setting`

String: defaults to the resource title.  The name of the setting to set.

##### `value`

String: no default.  The value to set.

##### `order`

String: default '10'.  The order in which to merge this setting.

### `mcollective::server::setting` defined type

`mcollective::server::setting` declares a setting that is exclusive to a server.

#### Parameters

##### `setting`

String: defaults to the resource title.  The name of the setting to set.

##### `value`

String: no default.  The value to set.

##### `order`

String: default '30'.  The order in which to merge this setting.

### `mcollective::client::setting` defined type

`mcollective::client::setting` declares a setting that is common to clients
and users.

#### Parameters

##### `setting`

String: defaults to the resource title.  The name of the setting to set.

##### `value`

String: no default.  The value to set.

##### `order`

String: default '30'.  The order in which to merge this setting.

### `mcollective::user::setting` defined type

`mcollective::user::setting` declares a setting that is specific to a user.

#### Parameters

##### `username`

String: required, no default.  Which user to set this value for.

##### `setting`

String: required, no default. The name of the setting to set.

##### `value`

String: no default.  The value to set.

##### `order`

String: default '70'.  The order in which to merge this setting.

### `mcollective::server::config::factsource::yaml` private class

`mcollective::server::config::factsource::yaml` is the class that implements
cron-based fact generation and configures MCollective to use it. It is a private
class and so may not be declared directly, but rather is invoked when the
`mcollective` class is declared with the `factsource` parameter set to `yaml`
(the default). Although `mcollective::server::config::factsource::yaml` is private
it does have one parameter which can be tuned using data bindings (e.g. Hiera).

#### Parameters

##### `path`

String: default $::path. What PATH environment variable to use when
refresh-mcollective-metadata is invoked by cron.

## Reference

### Configuration merging

The configuration of the server and client are built up from the various calls
to `mcollective::common::setting`, `mcollective::server::setting`,
`mcollective::client::setting`, and `mcollective::user::setting`.

Settings for the server will be a merge of `mcollective::common::setting` and
`mcollective::server::setting`, highest order of the setting wins.

Settings for the client will be a merge of `mcollective::common::setting`,
and `mcollective::client::setting`, highest order of the setting wins.

Settings for a specific user will be a merge of
`mcollective::common::setting`, `mcollective::client::setting` and
`mcollective::user::setting` for that specific user, highest order of setting
wins.

#### Overriding existing options

You can override an existing server setting from outside of the module by
simply specifying that setting again with a higher order than the default of
that type, for example to make a server's loglevel be debug (without simply
setting mcollective::server_loglevel) you could write:

```puppet
mcollective::server::setting { 'override loglevel':
  setting => 'loglevel',
  value   => 'debug',
  order   => '50',
}
```

## Troubleshooting

### Why do I have no client.cfg?

I said to install the client, so why when I run `mco ping` am I seeing this:

```shell
$ mco ping
Failed to generate application list: RuntimeError: Cannot find config file '/etc/mcollective/client.cfg'
```

You've enabled the ssl security provider, which implies each user will have
their own ssl credentials to use in the collective.  In order to avoid
incomplete configuration of clients in this mode we delete the system-wide
/etc/mcollective/client.cfg and only generate user configuration files with
the `mcollective::user` definition.

## Limitations

This module has been built on and tested against Puppet 3.0 and higher.

The module has been tested on:

* CentOS 6
* Ubuntu 12.04

Testing on other platforms has been light and cannot be guaranteed.

## Development

Puppet Community modules on are open projects, and community contributions are
essential for keeping them great. We can’t access the huge number of platforms
and myriad of hardware, software, and deployment configurations that Puppet is
intended to serve.

We want to keep it as easy as possible to contribute changes so that our
modules work in your environment. There are a few guidelines that we need
contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide [on the Puppet Labs wiki.](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing)

Current build status is: [![Build Status](https://api.travis-ci.org/voxpupuli/puppet-mcollective.png)](https://travis-ci.org/voxpupuli/puppet-mcollective)

