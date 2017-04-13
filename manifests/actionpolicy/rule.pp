# Define - mcollective::actionpolicy::rule
define mcollective::actionpolicy::rule(
  String $agent,
  Enum['allow', 'deny'] $action = 'allow',
  String $callerid              = '*',
  String $actions               = '*',
  String $fact_filter           = '*',
  String $classes               = '*'
) {
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
