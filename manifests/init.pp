# Class - mcollective
class mcollective (
  # which subcomponents to install here
  $server = true,
  $client = false,
  $middleware = false,

  # middleware tweaking
  $activemq_template = 'mcollective/activemq.xml.erb',
  $activemq_console = false, # ubuntu why you no jetty.xml!
  $activemq_config = undef,
  $activemq_base64 = true,
  $activemq_confdir = $mcollective::defaults::activemq_confdir,
  $rabbitmq_confdir = '/etc/rabbitmq',
  $rabbitmq_vhost = '/mcollective', # used by rabbitmq

  # installing packages
  $manage_packages = true,
  $version = 'present',

  # core configuration
  $main_collective = 'mcollective',
  $collectives = 'mcollective',
  $connector = 'activemq',
  $securityprovider = 'psk',
  $psk = 'changemeplease',
  $factsource = 'yaml',
  $yaml_fact_path = '/etc/mcollective/facts.yaml',
  $classesfile = '/var/lib/puppet/state/classes.txt',
  $rpcauthprovider = 'action_policy',
  $rpcauditprovider = 'logfile',
  $registration = undef,
  $core_libdir = $mcollective::defaults::core_libdir,
  $site_libdir = $mcollective::defaults::site_libdir,

  # networking
  $middleware_hosts = [],
  $middleware_user = 'mcollective',
  $middleware_password = 'marionette',
  $middleware_port = '61613',
  $middleware_ssl_port = '61614',
  $middleware_ssl = false,

  # server-specific
  $server_config_file   = '/etc/mcollective/server.cfg',
  $server_logfile       = '/var/log/mcollective.log',
  $server_loglevel      = 'info',
  $server_daemonize     = 1,
  $server_use_agent_ssl = false,
  $server_ssl_cert      = "${::puppet_vardir}/ssl/certs/${::fqdn}.pem",
  $server_ssl_key       = "${::puppet_vardir}/ssl/private_keys/${::fqdn}.pem",

  # client-specific
  $client_config_file = '/etc/mcollective/client.cfg',
  $client_logger_type = 'console',
  $client_loglevel = 'warn',

  # ssl certs
  $ssl_ca_cert = undef,
  $ssl_server_public = undef,
  $ssl_server_private = undef,
  $ssl_client_certs = 'puppet:///modules/mcollective/empty',
) inherits mcollective::defaults {
  anchor { 'mcollective::begin': }
  anchor { 'mcollective::end': }

  if $client or $server {
    # We don't want this on middleware roles.
    Anchor['mcollective::begin'] ->
    class { '::mcollective::common': } ->
    Anchor['mcollective::end']
  }
  if $client {
    Anchor['mcollective::begin'] ->
    class { '::mcollective::client': } ->
    Anchor['mcollective::end']
  }
  if $server {
    Anchor['mcollective::begin'] ->
    class { '::mcollective::server': } ->
    Anchor['mcollective::end']
  }
  if $middleware {
    Anchor['mcollective::begin'] ->
    class { '::mcollective::middleware': } ->
    Anchor['mcollective::end']
  }
}
