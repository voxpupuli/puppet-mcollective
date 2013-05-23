metadata    :name        => "proxmox",
            :description => "Display information about VM's",
            :author      => "Kevin Wolf",
            :license     => "",
            :version     => "0.2",
            :url         => "",
            :timeout     => 10

requires :mcollective => "2.2.0"

action "list", :description => "List of VM's running on host." do
    display :always

    output  :names,
            :description => "Name of VM's",
            :display_as  => "VM's"

    summarize do
        aggregate summary(:status)
    end
end

action "details", :description => "List details of VM's on this host" do
    display :always

    output  :vms,
            :description => "Detailed list of VMs",
            :display_as  => "VM's"

end

action "showstats", :description => "Show allocated stats for VM host." do
    display :always

    output  :totalmemory,
            :description => "Total RAM on host",
            :display_as  => "Total Mem"

    output  :memallocated,
            :description => "Amount of memory currently allocated to VM's",
            :display_as  => "Mem Alloc"

    output  :mempercentused,
            :description => "Percentage of total memory currently allocated to VM's",
            :display_as  => "% Mem Used"

    output  :procsallocated,
            :description => "VCPUs allocated to VM's",
            :display_as  => "Allocated VCPU's"

    output  :proccount,
            :description => "Total processors on host",
            :display_as  => "Total processors"
end
