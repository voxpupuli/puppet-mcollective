# This would be the module you put on all your nrpe-monitored nodes
class site_nagios::mcollective {
  # fake install nrpe
  file { ['/etc/nagios', '/etc/nagios/nrpe.d']:
      ensure => 'directory',
  }

  file { '/etc/nagios/nrpe.d/hello_world.cfg':
      content => "command[hello_world]=echo Hello World!\n",
  }

  mcollective::plugin { 'nrpe':
    package => true,
  }

  mcollective::actionpolicy { 'nrpe':
    default  => 'deny',
  }

  mcollective::actionpolicy::rule { 'root nrpe':
    agent    => 'nrpe',
    callerid => 'cert=root',
  }

  mcollective::actionpolicy::rule { 'nagios nrpe':
    agent    => 'nrpe',
    callerid => 'cert=nagios',
    actions  => 'runcommand',
  }
}
