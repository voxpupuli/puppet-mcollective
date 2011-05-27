# TODO #

 1. (DONE) Manage the package, file, service
 2. Deploy a default set of plugins
 3. Configure integration with facter
 4. Defined type to deploy other plugins
 5. Re-factor plugin management.  Don't mess with default plugin directory and
    instead recursively purge a second plugin directory.  e.g. in server.cfg
    add:
    libdir=/usr/libexec/mcollective:/var/lib/puppet/spool/mcollective/plugins



# GDL #

1. Add run stages instead of requires
2. Figure out Client Config Path --> config file default paths per distro.
3. OS X Package Support
4. Do we need to validate $config and others in init.pp?
5. Set Config and Config File in Params and Init to point to it.
6. Document that it's for 1.2.0


# TO REMOVE #

Host entry in init.pp
