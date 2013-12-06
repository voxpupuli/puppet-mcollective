# private class
class mcollective::server::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $mcollective::manage_packages {
    package { 'mcollective':
      ensure => $mcollective::version,
    }

    if $::osfamily == 'Debian' {
      # XXX the dependencies my test ubuntu 12.04 system seem to not correctly state
      # ruby-stomp as a dependency of mcollective, so hand specify
      package { 'ruby-stomp':
        ensure => 'installed',
        before => Package['mcollective'],
      }

      # fix for debian wheezy (guess ubuntu > 13.04 at least has the same), since mcollective has to use ruby1.8
      # but newer distros of debian has 1.9 by default.
      # http://projects.puppetlabs.com/issues/16572 - can be removed if fixed in .deb

      # 1. move ruby symlink away, cause you dont know where its pointing to
      exec { "${name}::move-ruby-symlink":
        command => '/bin/mv /usr/bin/ruby /usr/bin/ruby.backup',
      }

      # 2. create a temporary symlink pointing to ruby1.8 to be able to install mcollective without causing a puppet fail
      file { "${name}::ruby1.8-symlink":
        ensure => link,
        path => '/usr/bin/ruby',
        target => '/usr/bin/ruby1.8',
        require => Exec["${name}::move-ruby-symlink"],
        before => Package['mcollective'],
      }
      
      # 3. install package (handled by dependencies)

      # 4. stop service after installation
      exec { "${name}::mcollective-stopped":
          command => '/usr/sbin/service mcollective stop',
          require => Package['mcollective'],
      }

      # 5. change mcollectived shebang
      file_line {"${name}::mcollectived-shebang":
        path => "/usr/sbin/mcollectived",
        line => "#!/usr/bin/env ruby1.8",
        match => "#!/usr/bin/env ruby",
        require => Exec["${name}::mcollective-stopped"],
      }

      # 6. restore old ruby symlink and notify mcollective service
      exec { "${name}::restore-ruby-symlink":
        command => '/bin/rm /usr/bin/ruby && /bin/mv /usr/bin/ruby.backup /usr/bin/ruby',
        require => File_line["${name}::mcollectived-shebang"],
        notify => Service['mcollective']
      }
    }
  }
}
