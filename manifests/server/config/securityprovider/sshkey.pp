# private class
class mcollective::server::config::securityprovider::sshkey {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $mcollective::sshkey_server_learn_public_keys {
    # In the event the node is both a server and a client and they share a public key directory
    ensure_resource('file', $mcollective::sshkey_server_publickey_dir_real, {
      'ensure' =>  'directory',
      'mode'   =>  '0755', }
    )
  }

  # https://github.com/puppetlabs/mcollective-sshkey-security/blob/master/security/sshkey.rb

  mcollective::server::setting { 'plugin.sshkey.server.learn_public_keys':
    value => bool2num($mcollective::sshkey_server_learn_public_keys),
  }

  mcollective::server::setting { 'plugin.sshkey.server.overwrite_stored_keys':
    value => bool2num($mcollective::sshkey_server_overwrite_stored_keys),
  }

  if $mcollective::sshkey_server_publickey_dir_real {
    mcollective::server::setting { 'plugin.sshkey.server.publickey_dir':
      value => $mcollective::sshkey_server_publickey_dir_real,
    }
  }

  if $mcollective::sshkey_server_private_key {
    mcollective::server::setting { 'plugin.sshkey.server.private_key':
      value => $mcollective::sshkey_server_private_key,
    }
  }

  if $mcollective::sshkey_server_authorized_keys {
    mcollective::server::setting { 'plugin.sshkey.server.authorized_keys':
      value => $mcollective::sshkey_server_authorized_keys,
    }
  }

  if $mcollective::sshkey_server_send_key {
    mcollective::server::setting { 'plugin.sshkey.server.send_key':
      value => $mcollective::sshkey_server_send_key,
    }
  }
}
