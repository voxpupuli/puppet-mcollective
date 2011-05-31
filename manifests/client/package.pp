class mcollective::client::package(
  $version,
  $pkg_provider
) {

  #include 'mcollective::package'

  package { 'mcollective-client':
    ensure	  => $version,
    provider  => $pkg_provider,
  }
}
