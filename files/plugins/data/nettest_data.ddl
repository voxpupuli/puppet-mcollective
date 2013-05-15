metadata :name => "nettest",
         :description => "Checks if connecting to a host on a specified port is possible",
         :author => "Pieter Loubser <pieter.loubser@puppetlabs.com>",
         :license => "BSD",
         :version => "1.0.0",
         :url => "http://projects.puppetlabs.com/projects/mcollective-plugins/wiki",
         :timeout => 1

usage <<-END_OF_USAGE
Performs a check to see if Nettest Agent can connect to a host at a specific port.
Accepts an input parameter host:port.
Returns true if a connectioin can be made, false if not.

Usage:
  mco rpc rpcutil ping -S "Nettest('example.com:8080').connect=true"
END_OF_USAGE

requires :mcollective => '2.2.1'

dataquery :description => "connect" do
    input :query,
          :prompt => "Fqdn and port number",
          :description => "Valid Fqdn:port",
          :type => :string,
          :validation => :nettest_server_address,
          :maxlength => 50

    output :connect,
           :description => "True/false value of connected status",
           :display_as => "Connect"
end
