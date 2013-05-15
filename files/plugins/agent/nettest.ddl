metadata    :name        => "nettest",
            :description => "Agent to do network tests from a mcollective host",
            :author      => "Dean Smith <dean@zelotus.com>",
            :license     => "BSD",
            :version     => "3.0.2",
            :url         => "http://github.com/deasmi",
            :timeout     => 60

requires :mcollective => "2.2.1"

action "ping", :description => "Returns rrt of ping to host" do
    display :always

    input :fqdn,
          :prompt => "FQDN",
          :description => "The fully qualified domain name to ping",
          :type => :string,
          :validation => :nettest_fqdn,
          :optional => false,
          :maxlength => 80

    output :rtt,
           :description => "The round trip time in ms",
           :display_as=>"RTT"

    summarize do
      aggregate nettest_mma(:rtt, :format => "Min: %.3fms  Max: %.3fms  Average: %.3fms")
    end
end

action "connect", :description => "Check connectivity of remote server on port" do
    display :always

    input :fqdn,
          :prompt => "FQDN",
          :description => "The fully qualified domain name to ping",
          :validation => :nettest_fqdn,
          :type => :string,
          :optional => false,
          :maxlength => 80

    input :port,
          :prompt => "Port",
          :description => "The port to connect on",
          :type => :integer,
          :maxlength => 4,
          :optional => false

    output :connect,
           :description => "Boolean value stating if connection was possible",
           :display_as =>"Connected"

    output :connect_status,
           :description => "Connection status string",
           :display_as => "Connection Status"

    output :connect_time,
           :description => "Time it took to connect to host",
           :display_as => "Connection time"

    summarize do
      aggregate summary(:connect_status)
    end
end
