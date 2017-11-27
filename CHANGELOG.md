# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v3.1.0](https://github.com/voxpupuli/puppet-mcollective/tree/v3.1.0) (2017-11-26)

[Full Changelog](https://github.com/voxpupuli/puppet-mcollective/compare/v3.0.1...v3.1.0)

**Implemented enhancements:**

- Parameterize the client config [\#355](https://github.com/voxpupuli/puppet-mcollective/pull/355) ([BartWillems](https://github.com/BartWillems))
- Make client middleware cert configurable [\#348](https://github.com/voxpupuli/puppet-mcollective/pull/348) ([benningm](https://github.com/benningm))

**Fixed bugs:**

- use different delimiter for the sed at the puppet facts cronjob [\#358](https://github.com/voxpupuli/puppet-mcollective/pull/358) ([tampakrap](https://github.com/tampakrap))

**Merged pull requests:**

- reorder param docs to the Reference section [\#357](https://github.com/voxpupuli/puppet-mcollective/pull/357) ([bastelfreak](https://github.com/bastelfreak))
- modulesync 1.5.0 [\#356](https://github.com/voxpupuli/puppet-mcollective/pull/356) ([bastelfreak](https://github.com/bastelfreak))

## [v3.0.1](https://github.com/voxpupuli/puppet-mcollective/tree/v3.0.1) (2017-11-15)

[Full Changelog](https://github.com/voxpupuli/puppet-mcollective/compare/v3.0.0...v3.0.1)

**Fixed bugs:**

- Remove Yaml class serialization information [\#353](https://github.com/voxpupuli/puppet-mcollective/pull/353) ([jfroche](https://github.com/jfroche))
- fix redis implementation [\#350](https://github.com/voxpupuli/puppet-mcollective/pull/350) ([rwaffen](https://github.com/rwaffen))

**Merged pull requests:**

- release 3.0.1 [\#354](https://github.com/voxpupuli/puppet-mcollective/pull/354) ([bastelfreak](https://github.com/bastelfreak))
- Release 3.0.0 [\#352](https://github.com/voxpupuli/puppet-mcollective/pull/352) ([bastelfreak](https://github.com/bastelfreak))

## [v3.0.0](https://github.com/voxpupuli/puppet-mcollective/tree/v3.0.0) (2017-11-11)

[Full Changelog](https://github.com/voxpupuli/puppet-mcollective/compare/v2.5.0...v3.0.0)

**Breaking changes:**

- replace validate\_string with datatype [\#343](https://github.com/voxpupuli/puppet-mcollective/pull/343) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add option multiple ports [\#345](https://github.com/voxpupuli/puppet-mcollective/pull/345) ([mrodm](https://github.com/mrodm))

**Merged pull requests:**

- Use puppet facts instead of facter -p [\#346](https://github.com/voxpupuli/puppet-mcollective/pull/346) ([raphink](https://github.com/raphink))

## [v2.5.0](https://github.com/voxpupuli/puppet-mcollective/tree/v2.5.0) (2017-02-11)

This is the last release with Puppet3 support!
* Modulesync

## 2016-12-25 Release 2.4.0

- Modulesync with latest Vox Pupuli defaults
- Avoid compilation failure with strict_variables=true
- Make the rpcaudit.logfile configurable
- Add documentation for fact_cron_splay parameter

## 2016-09-08 Release 2.3.0

- Modulesync with latest Vox Pupuli defaults
- Create mco client config if also using sshkeyauth
- Add missing ssl_server_private
- User ssl files should thave an ensure parameter
- Fix puppet>=4 path handling
- Fix \_securityprovider call in user.pp
- Fix broken links in the README.md

## 2016-05-21 Release 2.2.0

Improvements:
- fix a few typos
- modulesync with latest voxpupuli defaults (0.6.2)
- enable splay for cron (#276)
- configure correct ssl (#281)
- add OpenBSD support (#220)
- update hiera lookup support (#220)
- Remove unneeded puppetlabs-concat dependency (#289)
- Add possibility to not purge the libdir directory (#291)
- Add service management configuration option (#292)
- Enable SSL Ciphers configuration (#290)

Bugfixes:
- Set correct libdir depending on mco version (#260)
- set correct runtime dependency for mcollective class and mcollectibe::plugin (#285)
- always set factsource and plugin.yaml settings with mcollective::server::setting

## 2015-12-11 Release 2.1.3

Summary:

This release comes with no big changes since 2.1.1. The biggest news is that
we ensure that the SSL directory for mcollective certs exists according to
the new AIO puppet-agent package, and some tests are refactor according to
Puppet > 4.

Bugfixes:
- Manage ssl directory for mcollective certs (9c845b23a6a3e734835725ba79d87bd3153babbd)

Styles:
- Moves `if...else` onto separate lines (a252f64c4cdb1d233b977b491fa107a6f6bb9b4d)
- Fixes bracket to same line as else (8d148502f3be8dd5f7f30fc17b6eb0c95935b2fd)

Improvements
- Datacat version bump from 0.5.x (ed3d6acd0b02d8d87d9bbc72c1243143c1cdf572)

## 2015-03-31 Release 2.1.1

Summary:

This release comes with no big changes since 2.0.0. The biggest news is that
we've moved to the "puppet" namespace on the forge, and the Voxpupuli space on
GitHub.

Bugfixes:
- fix propagation of middleware\_ssl\_fallback for rabbitmq
- Use string for host\_iteration titles in future parser ([MODULES-773](https://tickets.puppetlabs.com/browse/MODULES-773)
- Fix our Rakefile release task


## 2014-09-03 Release 2.0.0

Summary:

This is a fairly large rewrite of many parts of the mcollective module to
remove the management of activemq and rabbitmq (middleware) since this task
should be delegated to activemq/rabbitmq modules. See the examples/ directory
for example profiles to replicate previous configuration.

Backwards-incompatible Features:
- Removed the management of activemq and rabbitmq
- Removed the following parameters:
  - mcollective::middleware
  - mcollective::activemq\_template
  - mcollective::activemq\_memoryUsage
  - mcollective::activemq\_storeUsage
  - mcollective::activemq\_tempUsage
  - mcollective::activemq\_console
  - mcollective::activemq\_config
  - mcollective::activemq\_confdir
  - mcollective::rabbitmq\_confdir
  - mcollective::rabbitmq\_vhost
  - mcollective::delete\_guest\_user

Features:
- Make the confdir configurable
- Added callerid param for mcollective::user
- Replace facts.yaml pattern with cron job
- Allow mcollective::collectives to be an array
- Added the following parameters to class mcollective:
  - client\_package
  - confdir
  - rabbitmq\_vhost
  - service\_name
  - server\_package
  - ruby\_stomp\_package
  - ssl\_client\_certs\_dir

Bugfixes:
- Honor yaml\_fact\_path parameter in all the relevant places
- Use string for host\_iteration titles in future parser, as integers are not
allowed as titles

## 2014-07-15 Release 1.1.6

Summary:

This release updates metadata.json so the module can be uninstalled and
upgraded via the puppet module command, as well as fixes a documentation
typo.

## 2014-06-06 Release 1.1.5

Summary:

This is a bugfix release to get around dependency issues in PMT 3.6.

Fixes:
- Remove deprecated Modulefile as it was causing duplicate dependencies with PMT.

## 2014-06-04 Release 1.1.4

Summary:

This is a feature release that adds a number of new parameters.

Features:
- Add support for $activemq\_memoryUsage, $activemq\_storeUsage
  and $activemq\_tempUsage
- Add $ruby\_stomp\_ensure for manage ruby-stomp package
- Add support for $excluded\_facts
- Add support for $$middleware\_ssl\_fallback

## 2013-11-13 Release 1.1.3

Summary:

STOP IT PUPPET STOP. We've now fixed the problem for REAL, it was a missing
source and author field in the Modulefile.

## 2013-11-12 Release 1.1.2

Summary:

Metadata.json is persistent and made it into the tarball.

## 2013-10-21 Release 1.1.1

Summary:

This is a bugfix release, primarily to remove metadata.json, as it seems to
cause errors for some users.  Also exclude last\_run from the facts, and grant
rabbitmq's admin user configure permissions.

Fixes:
- Remove metadata.json
- Grant the rabbitmq admin user configure permissions.
- Add last\_run to the list of dynamic facts that are filtered out.

## 2013-10-11 Release 1.1.0

Summary:

This release adds `delete_guest_user` for RabbitMQ so that you don't have an
admin guest user left enabled.  It also adds `middleware_admin_user` and
`middleware_admin_password` so that you can control the user that's created in
the middleware appropriately.  The README has been updated with further
information.

Features:
- Add $delete\_guest\_user functionality.
- Add middleware\_admin\_user and middleware\_admin\_password parameters.
- Don't supply a client.cfg when securityprovider is 'ssl'

Fixes:
- Use hash to build anonymous hash (in order to not require future parser)

## 2013-10-03 Release 1.0.1

Summary:

Bugfixes.

Fixes:
- Stop puppet internals leaking into facts.yaml.
- Style fixes.
- Add plugin example to README.
- Update .travis.yml to test appropriately.


## 2013-09-27 Release 1.0.0

Summary:
The initial stable release of the mcollective module.


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*