#
class site_mcollective::client {
  mcollective::user { 'root':
    homedir     => '/root',
    certificate => "puppet:///modules/${module_name}/certs/root.pem",
    private_key => "puppet:///modules/${module_name}/private_keys/root.pem",
  }

  mcollective::user { 'vagrant':
    certificate => "puppet:///modules/${module_name}/certs/vagrant.pem",
    private_key => "puppet:///modules/${module_name}/private_keys/vagrant.pem",
  }
}
