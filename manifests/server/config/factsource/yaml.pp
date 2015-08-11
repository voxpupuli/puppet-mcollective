# private class
class mcollective::server::config::factsource::yaml {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $excluded_facts      = $mcollective::excluded_facts
  $yaml_fact_path_real = $mcollective::yaml_fact_path_real
  $ruby_shebang_path   = $::is_pe ? {
    true    => '/opt/puppet/bin/ruby',
    default => '/usr/bin/env ruby',
  }
  $yaml_fact_cron      = $mcollective::yaml_fact_cron

  # Template uses:
  #   - $ruby_shebang_path
  #   - $yaml_fact_path_real
  if $yaml_fact_cron {
    if versioncmp($::facterversion, '3.0.0') >= 0 {
      cron { 'refresh-mcollective-metadata':
        command     => "facter --yaml >${yaml_fact_path_real} 2>&1",
        environment => "PATH=/opt/puppet/bin:/opt/puppetlabs/bin:${::path}",
        user        => 'root',
        minute      => [ '0', '15', '30', '45' ],
      }
      exec { 'create-mcollective-metadata':
        path    => "/opt/puppet/bin:/opt/puppetlabs/bin:${::path}",
        command => "facter --yaml >${yaml_fact_path_real} 2>&1",
        creates => $yaml_fact_path_real,
      }
    } else {
      file { "${mcollective::site_libdir}/refresh-mcollective-metadata":
        owner   => '0',
        group   => '0',
        mode    => '0755',
        content => template('mcollective/refresh-mcollective-metadata.erb'),
      }
      cron { 'refresh-mcollective-metadata':
        command => "${mcollective::site_libdir}/refresh-mcollective-metadata >/dev/null 2>&1",
        user    => 'root',
        minute  => [ '0', '15', '30', '45' ],
        require => File["${mcollective::site_libdir}/refresh-mcollective-metadata"],
      }
      exec { 'create-mcollective-metadata':
        path    => "/opt/puppet/bin:${::path}",
        command => "${mcollective::site_libdir}/refresh-mcollective-metadata",
        creates => $yaml_fact_path_real,
        require => File["${mcollective::site_libdir}/refresh-mcollective-metadata"],
      }
    }
    mcollective::server::setting { 'factsource':
      value => 'yaml',
    }
    mcollective::server::setting { 'plugin.yaml':
      value => $yaml_fact_path_real,
    }
  }
}
