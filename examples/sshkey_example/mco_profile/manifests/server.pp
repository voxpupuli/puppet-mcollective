# Installs mcollective server components and configuration
class mco_profile::server  (
  $server_pubkey  = '/etc/ssh/ssh_host_rsa_key.pub',
  $server_privkey = '/etc/ssh/ssh_host_rsa_key',
) {
  # Validate the ssh keys for the server exist
  file { [$server_pubkey, $server_privkey]:
    ensure =>  'file',
    before =>  Class['mcollective'],
  }

  # Install sshkey plugin
  # Requires you to have obtained the security directory from https://github.com/puppetlabs/mcollective-sshkey-security
  # and placed it on your puppetmaster's file server
  mcollective::plugin { 'sshkey':
    source  =>  'puppet:///modules/profile/mco/plugins/sshkey',
  }

# Enable syslog output
#  mcollective::common::setting { 'use_syslog_logging':
#    setting => 'logger_type',
#    value   => 'syslog',
#    order   => '90',
#  }

# Set syslog facility
#  mcollective::common::setting { 'use_syslog_logging_facility':
#    setting => 'logfacility',
#    value   => 'user',
#    order   => '90',
#  }

  include ::mcollective
}
