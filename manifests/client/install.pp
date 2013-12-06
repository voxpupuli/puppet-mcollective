# private class
class mcollective::client::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $mcollective::manage_packages {
    package { 'mcollective-client':
      ensure => $mcollective::version,
    }

	if $::osfamily == 'Debian' {
      # fix for debian wheezy (guess ubuntu > 13.04 at least has the same), since mcollective has to use ruby1.8
      # but newer distros of debian has 1.9 by default.
      # http://projects.puppetlabs.com/issues/16572 - can be removed if fixed in .deb

      # change mco shebang
      file_line {"${name}::mco-shebang":
        path => "/usr/bin/mco",
        line => "#!/usr/bin/env ruby1.8",
        match => "#!/usr/bin/env ruby",
      }

  	}
  }
}
