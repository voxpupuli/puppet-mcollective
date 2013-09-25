# private define - mcollective::soft_include

# Attempts to include a class which may not exist.  If it does it also
# sandwiches it in between the $start and $end resources (typically anchors).
#
# This is somewhat useful as certain plugins may have specific options for
# client/server, for example the ssl securityprovider has the following classes:
#    mcollective::config::common::securityprovider::ssl
#    mcollective::config::client::securityprovider::ssl
#    mcollective::config::server::securityprovider::ssl
#
# But the psk securityprovider only needs a single common class:
#    mcollective::config::common::securityprovider::psk
#
# To avoid having empty server and client classes, instead in the
# respective common, client, and server classes we can soft_include
# mcollective::config::${role}::securityprovider::${mcollective::securityprovider}

define mcollective::soft_include($start, $end) {
  # does the class exist?
  if defined($name) {
    # declare it
    class { $name:
      require => $start,
      before  => $end,
    }
  }
}
