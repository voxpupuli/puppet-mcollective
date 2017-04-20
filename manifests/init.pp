# Class - mcollective
class mcollective (
  # which subcomponents to install here
  $server = true,
  $client = false,

  # installing packages
  $manage_packages        = true,
  $version                = 'present',
  $ruby_stomp_ensure      = 'installed',
  $sshkeyauth_gem_version = 'present',

  # core configuration
  $confdir          = $mcollective::defaults::confdir,
  $main_collective  = 'mcollective',
  $collectives      = 'mcollective',
  $connector        = 'activemq',
  $securityprovider = 'psk',
  $psk              = 'changemeplease',
  $factsource       = 'yaml',
  $yaml_fact_path   = undef,
  $yaml_fact_cron   = true,
  $fact_cron_splay  = false,
  $classesfile      = '/var/lib/puppet/state/classes.txt',
  $rpcauthprovider  = 'action_policy',
  $rpcauditprovider = 'logfile',
  $rpcauditlogfile  = '/var/log/mcollective-audit.log',
  $registration     = undef,
  $core_libdir      = $mcollective::defaults::core_libdir,
  $site_libdir      = $mcollective::defaults::site_libdir,
  $identity         = $fqdn,

  # networking
  $middleware_hosts          = [],
  $middleware_user           = 'mcollective',
  $middleware_password       = 'marionette',
  $middleware_multiple_ports = false,
  $middleware_port           = '61613',
  $middleware_ssl_port       = '61614',
  $middleware_ports          = ['61613'],
  $middleware_ssl_ports      = ['61614'],
  $middleware_ssl            = false,
  $middleware_ssl_fallback   = false,
  $middleware_ssl_cert       = undef,
  $middleware_ssl_key        = undef,
  $middleware_ssl_ca         = undef,
  $middleware_admin_user     = 'admin',
  $middleware_admin_password = 'secret',
  $middleware_heartbeat_interval = '30',

  # middleware connector tweaking
  $rabbitmq_vhost = '/mcollective',

  # common
  $common_package = 'mcollective-common',

  # server-specific
  $server_config_file = undef, # default dependent on $confdir
  $server_logfile     = '/var/log/mcollective.log',
  $server_loglevel    = 'info',
  $server_daemonize   = $mcollective::defaults::server_daemonize,
  $service_name       = 'mcollective',
  $service_ensure     = 'running',
  $service_enable     = true,
  $server_package     = 'mcollective',
  $ruby_stomp_package = 'ruby-stomp',
  $ruby_interpreter   = $mcollective::defaults::ruby_interpreter,

  # client-specific
  $client_config_file  = undef, # default dependent on $confdir
  $client_logger_type  = 'console',
  $client_loglevel     = 'warn',
  $client_package      = 'mcollective-client',

  # ssl certs
  $ssl_ca_cert          = undef,
  $ssl_server_public    = undef,
  $ssl_server_private   = undef,
  $ssl_client_certs     = 'puppet:///modules/mcollective/empty',
  $ssl_client_certs_dir = undef, # default dependent on $confdir

  # ssl ciphers
  $ssl_ciphers = undef,

  # Action policy settings
  $allowunconfigured    = '1',

  # Sshkey security provider settings
  # Module defaults: https://github.com/puppetlabs/mcollective-sshkey-security/blob/master/security/sshkey.rb
  $sshkey_server_learn_public_keys      = false,
  $sshkey_server_overwrite_stored_keys  = false,
  $sshkey_server_publickey_dir          = undef, #overwritten below
  $sshkey_server_private_key            = '/etc/ssh/ssh_host_rsa_key',
  $sshkey_server_authorized_keys        = undef,
  $sshkey_server_send_key               = undef,
) inherits mcollective::defaults {

  # Because the correct default value for several parameters is based on another
  # configurable parameter, it cannot be set in the parameter defaults above and
  # _real variables must be set here.
  $yaml_fact_path_real = pick_default($yaml_fact_path, "${confdir}/facts.yaml")
  $server_config_file_real = pick_default($server_config_file, "${confdir}/server.cfg")
  $client_config_file_real = pick_default($client_config_file, "${confdir}/client.cfg")

  $ssldir = "${confdir}/ssl"

  $ssl_client_certs_dir_real = pick_default($ssl_client_certs_dir, "${ssldir}/clients")
  $ssl_server_public_path    = "${ssldir}/server_public.pem"
  $ssl_server_private_path   = "${ssldir}/server_private.pem"

  $middleware_ssl_ca_real   = pick_default($middleware_ssl_ca, $ssl_ca_cert)
  $middleware_ssl_cert_real = pick_default($middleware_ssl_cert, $ssl_server_public)
  $middleware_ssl_key_real  = pick_default($middleware_ssl_key, $ssl_server_private)

  $middleware_ssl_key_path  = "${ssldir}/middleware_key.pem"
  $middleware_ssl_cert_path = "${ssldir}/middleware_cert.pem"
  $middleware_ssl_ca_path   = "${ssldir}/middleware_ca.pem"

  if $securityprovider == 'sshkey' {
    package{'sshkeyauth':
      ensure   =>  $sshkeyauth_gem_version,
      provider =>  'puppet_gem',
    }
  }

  if $sshkey_server_learn_public_keys {
    $sshkey_server_publickey_dir_real = pick($sshkey_server_publickey_dir,"${confdir}/sshkey_pubkeys")
  }

  if $client or $server {
    contain ::mcollective::common
  }
  if $client {
    contain ::mcollective::client
  }
  if $server {
    contain ::mcollective::server
  }
}
