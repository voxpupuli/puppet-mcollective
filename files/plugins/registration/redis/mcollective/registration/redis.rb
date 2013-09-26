module MCollective
  module Registration
    # A registration plugin that sends in all the metadata we have for a node
    # to redis, this will only work with the Redis connector and no other
    # connector
    #
    # Metadata being sent:
    #
    # - all facts
    # - all agents
    # - all classes (if applicable)
    # - the configured identity
    # - the list of collectives the nodes belong to
    # - last seen time
    #
    # Keys will be set to expire (2 * registration interval) + 2
    class Redis<Base
      def body
        data = {:agentlist => [],
                :facts => {},
                :classes => [],
                :collectives => []}

        identity = Config.instance.identity

        cfile = Config.instance.classesfile

        if File.exist?(cfile)
          data[:classes] = File.readlines(cfile).map {|i| i.chomp}
        end

        data[:identity] = Config.instance.identity
        data[:agentlist] = Agents.agentlist
        data[:facts] = PluginManager["facts_plugin"].get_facts
        data[:collectives] = Config.instance.collectives.sort

        commit = lambda do |redis|
          begin
            time = Time.now.utc.to_i

            redis.multi do
              data[:collectives].each {|c| redis.zadd "mcollective::collective::#{c}", time, data[:identity]}
              data[:agentlist].each {|a| redis.zadd "mcollective::agent::#{a}", time, data[:identity]}
              data[:classes].each {|c| redis.zadd "mcollective::class::#{c}", time, data[:identity]}

              redis.del "mcollective::facts::#{data[:identity]}"
              redis.hmset "mcollective::facts::#{data[:identity]}", data[:facts].map{|k, v| [k.to_s, v.to_s]}.flatten
            end
          rescue => e
            Log.error("%s: %s: %s" % [e.backtrace.first, e.class, e.to_s])
          end
        end

        PluginManager["connector_plugin"].sender_queue << {:command => :proc, :proc => commit}
        nil
      end
    end
  end
end
