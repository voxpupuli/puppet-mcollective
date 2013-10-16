# mcollective

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with mcollective](#setup)
    * [What the mcollective module affects](#what-the-mcollective-module-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with mcollective](#beginning-with-mcollective)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

The mcollective module installs, configures, and manages the mcollective
agents, clients, and middleware of an mcollective cluster.

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

On a middleware host

* broker installation
* broker configuration

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
  class { '::mcollective':
    middleware       => true,
    middleware_hosts => [ 'broker1.example.com' ],
  }
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
  class { '::mcollective':
    middleware         => true,
    middleware_hosts   => [ 'broker1.example.com' ],
    middleware_ssl     => true,
    securityprovider   => 'ssl',
    ssl_client_certs   => 'puppet:///modules/site_mcollective/client_certs',
    ssl_ca_cert        => 'puppet:///modules/site_mcollective/certs/ca.pem',
    ssl_server_public  => 'puppet:///modules/site_mcollective/certs/server.pem',
    ssl_server_private => 'puppet:///modules/site_mcollective/private_keys/server.pem',
  }
}

node 'server1.example.com' {
  class { '::mcollective':
    middleware_hosts   => [ 'broker1.example.com' ],
    middleware_ssl     => true,
    securityprovider   => 'ssl',
    ssl_client_certs   => 'puppet:///modules/site_mcollective/client_certs',
    ssl_ca_cert        => 'puppet:///modules/site_mcollective/certs/ca.pem',
    ssl_server_public  => 'puppet:///modules/site_mcollective/certs/server.pem',
    ssl_server_private => 'puppet:///modules/site_mcollective/private_keys/server.pem',
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
    client             => true,
    middleware_hosts   => [ 'broker1.example.com' ],
    middleware_ssl     => true,
    securityprovider   => 'ssl',
    ssl_client_certs   => 'puppet:///modules/site_mcollective/client_certs',
    ssl_ca_cert        => 'puppet:///modules/site_mcollective/certs/ca.pem',
    ssl_server_public  => 'puppet:///modules/site_mcollective/certs/server.pem',
    ssl_server_private => 'puppet:///modules/site_mcollective/private_keys/server.pem',
  }

  mcollective::user { 'vagrant':
    certificate => 'puppet:///modules/site_mcollective/client_certs/vagrant.pem',
    private_key => 'puppet:///modules/site_mcollective/private_keys/vagrant.pem',
  }
}
```

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

##### `middleware`

Boolean: defaults to false.  Whether to install middleware that matches
`$mcollective::connector` on this node.


##### `activemq_template`

String: defaults to 'mcollective/activemq.xml.erb'.  Template to use when
configuring activemq middleware.

##### `activemq_console`

Boolean: defaults to false.  Whether to enable the jetty admin console when
configuring the activemq middleware.

##### `activemq_config`

String: defaults to undef.  If supplied the contents of the activemq.xml
configuration file to use when configuring activemq middleware.  Bypasses
`mcollective::activemq_template`

##### `activemq_confdir`

String: default based on distribution.  The directory to copy ssl certificates
to when configuring activemq middleware with `mcollective::middleware_ssl`.

##### `rabbitmq_confdir`

String: defaults to '/etc/rabbitmq'. The directory to copy ssl certificates to
when configuring rabbitmq middleware with `mcollective::middleware_ssl`.

##### `rabbitmq_vhost`

String: defaults to '/mcollective'.  The vhost to connect to/manage when using
rabbitmq middleware.

##### `delete_guest_user`

Boolean: defaults to 'false'.  Whether to delete the rabbitmq guest user when
setting up rabbitmq middleware.

##### `manage_packages`

Boolean: defaults to true.  Whether to install mcollective and mcollective-
client packages when installing the server and client components.

##### `version`

String: defaults to 'present'.  What version of packages to `ensure` when
`mcollective::manage_packages` is true.

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

##### `yaml_fact_path`

String: defaults to '/etc/mcollective/facts.yaml'.  Name of the file the
'yaml' factsource plugin should load facts from.

##### `classesfile`

String: defaults to '/var/lib/puppet/state/classes.txt'.  Name of the file the
server will load the configuration management class for filtering.

##### `rpcauthprovider`

String: defaults to 'action_policy'.  Name of the RPC Auth Provider to use on
the server.

##### `rpcauditprovider`

String: defaults to 'logfile'.  Name of the RPC Audit Provider to use on the
server.

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

String: defaults to '61613'.  Port number to use when connecting to the
middleware over an unencrypted connection.

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

String: default is '/etc/mcollective/server.cfg'.  Path to the server
configuration file.

##### `server_logfile`

String: defaults to '/var/log/mcollective.log'.  Logfile the mcollective
server should log to.

##### `server_loglevel`

String: defaults to 'info'.  Level the mcollective server should log at.

##### `server_daemonize`

String: defaults to '1'.  Should the mcollective server daemonize when
started.

##### `client_config_file`

String: defaults to '/etc/mcollective/client.cfg'.  Path to the client
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
Used by the 'ssl' securityprovider to set the identity of the user.

##### `private_key`

String: defaults to undef.  A file source for the private key of the user.
Used when `mcollective::middleware_ssl` is true to connect to the middleware
and by the 'ssl' securityprovider to sign messages as from this user.

### `mcollective::plugin` defined type

`mcollective::plugin` installs a plugin from a source uri or a package.  When
installing from a source uri the plugin will be copied to
`mcollective::site_libdir`

```puppet
mcollective::plugin { 'puppet':
  package => true,
}

mcollective::plugin { 'myplugin':
  source => 'puppet:///modules/site_mcollective/plugins',
}
```

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
entry.

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

##### `facts`

String: defaults to '*'.  What facts should match this rule.

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

Puppet Labs modules on the Puppet Forge are open projects, and community
contributions are essential for keeping them great. We can’t access the
huge number of platforms and myriad of hardware, software, and deployment
configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our
modules work in your environment. There are a few guidelines that we need
contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide [on the Puppet Labs wiki.](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing)

Current build status is: [![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-mcollective.png)](https://travis-ci.org/puppetlabs/puppetlabs-mcollective)

