module MCollective
    module Agent
        class Proxmox<RPC::Agent
            $columns = %w(vmid name status mem(mb) bootdisk(gb) pid)
            $vm_list = nil

            activate_when do
                File.exists? "/usr/sbin/qm"
            end

            action "list" do
                Log.debug("Starting list action proxmox agent.")
                reply[:names] = getnames
            end

            action "details" do
                Log.debug("Starting detail action proxmox agent.")
                reply[:vms] = getvms
            end

            action "showstats" do
                Log.debug("Starting stats action proxmox agent.")
                reply[:memallocated] = getmemoryused
                reply[:totalmemory] = gettotalmemory
                reply[:mempercentused] = calcmemused(reply[:totalmemory], reply[:memallocated])
                reply[:procsallocated] = getallocprocessors
                reply[:proccount] = Facts['processorcount'].to_i
            end

            private

            def calcmemused(total, used)
                used = Float(used) / Float(total)
                "%.2f" % used 
            end

            def getallocprocessors
                vm_list = getlist
                procs = 0
                vm_list.each do |vm|
                    t = getvmstatus(vm['vmid'], 'cpus')
                    procs += t.to_i
                end

                procs
            end

            def gettotalmemory
                totalmemory = Facts["memorytotal"].to_f
                totalmemory = totalmemory * 1024
                totalmemory.round
            end

            def getmemoryused
                vm_list = getlist
                memory = 0

                vm_list.each do |vm|
                    memory += vm["mem(mb)"].to_i
                end

                Log.debug("Memory Allocated:  #{memory}")
                memory
            end

            def getvms
                vm_list = getlist
                vms = Array.new
                headers = "%5s  %20s  %8s  %7s  %11s  %5s"
                format = "%5d  %20s  %8s  %7d  %12.1f  %5d"

                vms << (headers % $columns).upcase

                vm_list.each do |vm|
                    vms << format % [vm['vmid'], vm['name'], vm['status'], vm['mem(mb)'], 
                            vm['bootdisk(gb)'], vm['pid']]
                end

                vms
            end

            def getnames
                vm_list = getlist
                names = Array.new

                vm_list.each do |vm|
                    names << vm['name'] if vm['name']
                end

                names
            end

            def getlist
                return $vm_list if $vm_list
                Log.debug("Getting list of VM's")

                vmid, name, status, mem, disk, pid = 0,1,2,3,4,5

                out = ""
                err = [] 
                status = run("/usr/sbin/qm list", :stdout => out, :stderr => err)
                reply.fail! "Failed to get VM list." unless status  == 0

                vm_array = out.split(/\n/)
                reply[:err] = err unless err.empty?
                vm_array.delete_at(0)  # Delete header row.
                result = Array.new()

                vm_array.each do |line|
                    vm = line.split
                    h = Hash.new()

                    $columns.each_with_index do |column, index|
                        h[column] = vm[index]
                    end
                    result << h
                end

                $vm_list = result
            end

            def getvmstatus(vmid, stat)
                out = ""
                run("/usr/sbin/qm status #{vmid} -verbose | /bin/grep #{stat} | /usr/bin/awk '{print $NF}'", :stdout => out)
                out
            end
        end
    end
end
