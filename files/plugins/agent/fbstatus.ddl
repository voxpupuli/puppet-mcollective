metadata    :name           => "SimpleRPC Fundbutter mon.jsp Agent.",
            :description    => "Interface to Fundbutter's mon.jsp monitoring page",
            :author         => "Kevin Wolf",
            :license        => "Apache v.2",
            :url            => "",
            :version        => "0.1",
            :timeout        => 2

action "status", :description => "Displays the status of Fundbutter based on mon.jsp" do
    display :failed

    output :msg,
        :description    => "Status of Fundbutter",
        :display_as     => "Message"
end

action "monitor", :description => "Return result of specified monitor using mon.jsp." do
    display :always

    input   :monitor,
            :prompt         => "Monitor",
            :description    => "Monitor to return",
            :type           => :string,
            :validation     => '^.*$',
            :optional       => false,
            :maxlength      => 50

    output :msg,
            :description    => "Status of monitor",
            :display_as     => "Value"
end
