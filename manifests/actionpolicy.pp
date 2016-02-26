# Define - mcollective::actionpolicy
# Sets up the actionpolicy for an agent
# Install them with mcollective::plugin
# Namevar will be the name of the agent to configure
define mcollective::actionpolicy($default = 'deny') {

  include ::mcollective

  datacat { "mcollective::actionpolicy ${name}":
    owner    => 'root',
    group    => '0',
    mode     => '0400',
    path     => "${mcollective::confdir}/policies/${name}.policy",
    template => 'mcollective/actionpolicy.erb',
  }

  datacat_fragment { "mcollective::actionpolicy ${name} actionpolicy default":
    target => "mcollective::actionpolicy ${name}",
    data   => {
      'default' => $default,
    },
  }
}
