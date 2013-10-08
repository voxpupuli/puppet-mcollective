# private class
# This class is for setting the few platform defaults that need branching; all
# other configuration should be defaulted using the class paramaters to the
# mcollective class.
# Never refer to $mcollective::defaults::foo values outside of a parameter
# list, it's leak and prevents users from actually having control.
class mcollective::defaults {
  $core_libdir = $::osfamily ? {
    'Debian' => '/usr/share/mcollective/plugins',
    'windows' => 'c:\marionette-collective\plugins',
    default  => '/usr/libexec/mcollective',
  }

  # Where this module will sync file-managed plugins to.
  # These paths may need revisiting by someone who understands FHS and
  # distribution standards for site-specific application-specific
  # library paths.
  $site_libdir = $::osfamily ? {
    'Debian' => '/usr/local/share/mcollective',
    'windows' => 'c:\marionette-collective\plugins',
    default  => '/usr/local/libexec/mcollective',
  }

  $activemq_confdir = $::osfamily ? {
    'Debian' => '/etc/activemq/instances-available/mcollective',
    default  => '/etc/activemq',
  }
  
  $yaml_fact_path = $::osfamily ? {
	'windows'	=> 'c:\marionette-collective\etc\facts.yaml',
    default 	=> '/etc/mcollective/facts.yaml',
  }

  $classesfile = $::osfamily ? {
	'windows'	=> 'C:\ProgramData\PuppetLabs\puppet\var\state\classes.txt',
    default 	=> '/var/lib/puppet/state/classes.txt',
  }

  $config_path = $::osfamily ? {
	'windows'	=> 'C:\marionette-collective\etc',
    default 	=> '/etc/mcollective',
  }

  $logfile = $::osfamily ? {
	'windows'	=> 'C:\marionette-collective\mcollective.log',
    default 	=> '/var/log/mcollective.log',
  }

}
