class mcollective::client::package(
  $version
) {

  package { 'mcollective-client':
    ensure	  => $version,
  }
}

