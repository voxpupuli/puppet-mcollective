# Installs Mcollective client code and deploys user credentials
# This utilizes the dynamic sshkey deployment method
# This also assumes that your client is going to be deployed
# on the same system as your server code
class mco_profile::client  {
  $mcollective_users = hiera_hash('mcollective::userconfigs')

  # Set defaults for all mcollective::user resources
  Mcollective::User {
    sshkey_learn_public_keys      => true,
    sshkey_overwrite_stored_keys  => true,
    sshkey_enable_private_key     => true,
    sshkey_enable_send_key        => true,
  }
  # Refer to hiera documentation on merging if a more complex scenario is needed
  create_resources('mcollective::user',$mcollective_users)
}
