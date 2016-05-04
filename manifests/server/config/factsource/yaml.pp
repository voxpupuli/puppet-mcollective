# private class
class mcollective::server::config::factsource::yaml (
  $path = $::path,
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $yaml_fact_path_real = $mcollective::yaml_fact_path_real
  $ruby_shebang_path   = $mcollective::ruby_interpreter
  $yaml_fact_cron      = $mcollective::yaml_fact_cron

  if $mcollective::fact_cron_splay {
    $cron_minute_offset  = fqdn_rand(15, $::macaddress)
    $cron_minutes        = [
                            $cron_minute_offset,
                            $cron_minute_offset + 15,
                            $cron_minute_offset + 30,
                            $cron_minute_offset + 45,
                          ]
  } else {
    $cron_minutes = [ '0', '15', '30', '45' ]
  }

  # Template uses:
  #   - $ruby_shebang_path
  #   - $yaml_fact_path_real
  if $yaml_fact_cron {
    if versioncmp($::facterversion, '3.0.0') >= 0 {
      cron { 'refresh-mcollective-metadata':
        command     => "facter -p --yaml >${yaml_fact_path_real} 2>&1",
        environment => 'PATH=/opt/puppet/bin:/opt/puppetlabs/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        user        => 'root',
        minute      => $cron_minutes,
      }
      exec { 'create-mcollective-metadata':
        path    => "/opt/puppet/bin:/opt/puppetlabs/bin:${::path}",
        command => "facter -p --yaml >${yaml_fact_path_real} 2>&1",
        creates => $yaml_fact_path_real,
      }
    } else {
      file { "${mcollective::site_libdir}/refresh-mcollective-metadata":
        owner   => '0',
        group   => '0',
        mode    => '0755',
        content => template('mcollective/refresh-mcollective-metadata.erb'),
      }

      # There is concern that cron jobs run with a reduced PATH, so we still
      # want to invoke this script with at least as full a path as the Puppet
      # service has itself. We want to avoid the environment parameter to set
      # PATH as environment is global. Therefore, prefix the command itself in
      # the cron job with the value of the PATH environment variable to use.
      cron { 'refresh-mcollective-metadata':
        command => "/bin/sh -c 'export PATH=${path}; ${mcollective::site_libdir}/refresh-mcollective-metadata >/dev/null 2>&1'",
        user    => 'root',
        minute  => $cron_minutes,
        require => File["${mcollective::site_libdir}/refresh-mcollective-metadata"],
      }

      exec { 'create-mcollective-metadata':
        path    => "/opt/puppet/bin:${::path}",
        command => "${mcollective::site_libdir}/refresh-mcollective-metadata",
        creates => $yaml_fact_path_real,
        require => File["${mcollective::site_libdir}/refresh-mcollective-metadata"],
      }
    }
  }

  mcollective::server::setting { 'factsource':
    value => 'yaml',
  }
  mcollective::server::setting { 'plugin.yaml':
    value => $yaml_fact_path_real,
  }
}
