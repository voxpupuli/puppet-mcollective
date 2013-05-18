module MCollective
    class Application::Fbstatus<Application
        description "Interact with mon.jsp for FundButter servers."
        usage "Usage: mco fbstatus [-m MONITOR]"

        option :monitor,
               :description   => "Monitor to check",
               :arguments     => ["--monitor MONITOR", "-m MONITOR"],
               :requited      => false,
               :type          => :string

        def main
            mc = rpcclient('fbstatus')
            mc.class_filter /fb/

            if configuration[:monitor]
                printrpc mc.monitor(:monitor => configuration[:monitor])
            else
                printrpc mc.status(), :verbose => configuration[:verbose]
            end

            halt mc.stats
        end
    end
end
