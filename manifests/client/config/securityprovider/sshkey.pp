# private class
class mcollective::client::config::securityprovider::sshkey {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }
  
  ensure_packages('sshkeyauth', {
    'ensure'   =>  'present',
    'provider' =>  'puppet_gem', }
  )
  
  if $mcollective::sshkey_client_learn_public_keys {
    # In the event the node is both a server and a client and they share a public key directory
    ensure_resource('file', $mcollective::sshkey_client_publickey_dir_real, {
      'ensure' =>  'directory',
      'mode'   =>  '0755', }
    )
  }

  # https://github.com/puppetlabs/mcollective-sshkey-security/blob/master/security/sshkey.rb

  mcollective::client::setting { 'plugin.sshkey.client.learn_public_keys':
    value => $mcollective::sshkey_client_learn_public_keys_real,
  }

  mcollective::client::setting { 'plugin.sshkey.client.overwrite_stored_keys':
    value => $mcollective::sshkey_client_overwrite_stored_keys_real,
  }
  
  if $mcollective::sshkey_client_publickey_dir_real {
    mcollective::client::setting { 'plugin.sshkey.client.publickey_dir':
      value => $mcollective::sshkey_client_publickey_dir_real,
    }
  }

  if $mcollective::sshkey_client_private_key {  
    mcollective::client::setting { 'plugin.sshkey.client.private_key':
      value => $mcollective::sshkey_client_private_key,
    }
  }
    
  if $mcollective::sshkey_client_known_hosts {
    mcollective::client::setting { 'plugin.sshkey.client.known_hosts':
      value => $mcollective::sshkey_client_known_hosts,
    }
  }
  
  if $mcollective::sshkey_client_send_key {
    mcollective::client::setting { 'plugin.sshkey.client.send_key':
      value => $mcollective::sshkey_client_send_key,
    }
  }
}
