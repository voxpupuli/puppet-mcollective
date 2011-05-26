# TODO #

 1. (DONE) Manage the package, file, service
 2. Deploy a default set of plugins
 3. Configure integration with facter
 4. Defined type to deploy other plugins
 5. Re-factor plugin management.  Don't mess with default plugin directory and
    instead recursively purge a second plugin directory.  e.g. in server.cfg
    add:
    libdir=/usr/libexec/mcollective:/var/lib/puppet/spool/mcollective/plugins

