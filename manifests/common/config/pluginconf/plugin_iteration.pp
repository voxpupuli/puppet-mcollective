# private define
define mcollective::common::config::pluginconf::plugin_iteration {
  mcollective::common::setting { "plugin.${name}":
    value => $mcollective::pluginconf[$name],
  }
}
