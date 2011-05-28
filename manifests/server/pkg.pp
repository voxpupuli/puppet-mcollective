class mcollective::server::pkg(
  $version,
  $pkg_provider
) {

  #include 'mcollective::pkg'

  package { 'mcollective':
    ensure	  => $version,
    provider  => $pkg_provider,
  }
}
