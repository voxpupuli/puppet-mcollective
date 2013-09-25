# Define - mcollective::actionpolicy::rule
define mcollective::actionpolicy::rule(
  $agent,
  $action   = 'allow',
  $callerid = '*',
  $actions  = '*',
  $facts = '*',
  $classes = '*'
) {
  datacat_fragment { "mcollective::actionpolicy::rule ${title}":
    target => "mcollective::actionpolicy ${agent}",
    data   => {
      lines => [
        {
          'action'   => $action,
          'callerid' => $callerid,
          'actions'  => $actions,
          'facts'    => $facts,
          'classes'  => $classes,
        },
      ],
    },
  }
}
