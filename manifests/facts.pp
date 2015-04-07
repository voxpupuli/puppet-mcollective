#The facts.yaml file resource is generated in its own dedicated class
#By doing this, the file produced isn't polluted with unwanted in scope class variables.

##Bring in as many variables as you want from other classes here.
#This makes them available to mcollective for use in filters.
#eg
#$class_variable = $class::variable

#mcollective doesn't work with arrays, so use the puppet-stdlib join function
#eg
class mcollective::facts ()
{
  $ntp_servers = join($ntp::servers, ",")
  file{'/etc/mcollective/facts.yaml':
    owner   => root,
    group   => root,
    mode    => 400,
    content => template('mcollective/facts.yaml.erb'),
  }
}
