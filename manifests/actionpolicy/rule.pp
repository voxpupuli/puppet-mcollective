# Define - mcollective::actionpolicy::rule
define mcollective::actionpolicy::rule(
  $agent,
  $action      = 'allow',
  $callerid    = '*',
  $actions     = '*',
  $fact_filter = '*',
  $classes     = '*'
) {
  validate_string($fact_filter)
  datacat_fragment { "mcollective::actionpolicy::rule ${title}":
    target => "mcollective::actionpolicy ${agent}",
    data   => {
      lines => [
        {
          'action'   => $action,
          'callerid' => $callerid,
          'actions'  => $actions,
          'facts'    => $fact_filter,
          'classes'  => $classes,
        },
      ],
    },
  }
}
