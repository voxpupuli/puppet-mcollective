module MCollective
    class Application::Proxmox<Application
        description "Proxmox interface to query information about VM's"
        usage "Usage:  mco proxmox <list | details>"

        option  :runningonly,
                :arguments      => ['--running-only'],
                :description    => "Consider only VM's that are currently running.",
                :type           => :bool,
                :default        => false

        def post_option_parser(configuration)
            if ARGV.length >= 1
                configuration[:command] = ARGV.shift
            else
                configuration[:command] = "list"
            end
        end

        def main
            proxmox = rpcclient("proxmox")

            rpcresults = proxmox.send(configuration[:command])

            printrpc rpcresults, :verbose => configuration[:verbose]
            
            printrpcstats :summarize => true

            halt proxmox.stats
        end

    end
end
