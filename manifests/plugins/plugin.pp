define mcollective::plugins::plugin(
  $type,
  $ensure      = present,
  $ddl         = false,
  $application = false,
  $plugin_base = $mcollective::params::plugin_base
) {

  include mcollective::params

  if $plugin_base == '' {
    $plugin_base_real = $mcollective::params::plugin_base
  } else {
    $plugin_base_real = $plugin_base
  }

  if ($ddl == true or $application == true) and $type != 'agent' {
    fail('DDLs and Applications only apply to Agent plugins')
  }

  file { "${plugin_base_real}/${type}/${name}.rb":
    ensure => $ensure,
    source => "puppet:///modules/mcollective/plugins/${type}/${name}.rb",
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    notify => Class['mcollective::server::service'],
  }

  if $ddl {
    file { "${plugin_base_real}/${type}/${name}.ddl":
      ensure => $ensure,
      source => "puppet:///modules/mcollective/plugins/${type}/${name}.ddl",
      mode   => '0644',
      owner  => 'root',
      group  => 'root',
    }
  }

  if $application {
    file { "${plugin_base_real}/application/${name}.rb":
      ensure => $ensure,
      source => "puppet:///modules/mcollective/plugins/${type}/application/${name}.rb",
      mode   => '0644',
      owner  => 'root',
      group  => 'root',
    }
  }

}
