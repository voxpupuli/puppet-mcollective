metadata :name => "nettest_fqdn",
         :description => "Validates that a string is a fully qualified domain name",
         :author => "P. Loubser <pieter.loubser@puppetlabs.com>",
         :license => "BSD",
         :version => "1.0.0",
         :url => "http://marionette-collective.org/",
         :timeout => 1

usage <<-END_OF_USAGE
Validates if a given string is a valid fqdn. Will succesfully validate on a valid ipv4 address as well as a valid hostname.

In a DDL :
  validation => :fqdn

In code :
   MCollective::Validator.validate("1.2.3.4", :fqdn)

END_OF_USAGE
