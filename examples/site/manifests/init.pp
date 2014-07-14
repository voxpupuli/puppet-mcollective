# This class exists solely to aggregate the set of information that tie
# together the MCollective middleware.
#
class site (
  $main_collective     = undef,
  $collectives         = undef,
  $middleware_hosts    = undef,
  $middleware_username = undef,
  $middleware_password = undef,
  $middleware_ssl_port = undef,
  $ssl_server_public   = undef,
  $ssl_server_private  = undef,
  $ssl_server_ca       = undef,
  $connector           = undef,
) {

  # No resources are declared by this class.

}
