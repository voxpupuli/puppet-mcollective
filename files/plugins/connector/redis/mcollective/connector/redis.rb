require 'redis'
require 'ostruct'

module MCollective
  module Connector
    # A basic connector for mcollective using Redis.
    #
    # It is not aimed at large deployments more aimed as a getting
    # starter / testing style setup which would be easier for new
    # users to evaluate mcollective
    #
    # It supports direct addressing and sub collectives
    #
    # We'd also add a registration plugin for it and a discovery
    # plugin which means we can give a very solid fast first-user
    # experience using this
    #
    # Configure it with:
    #
    #    plugin.redis.host = localhost
    #    plugin.redis.port = 6379
    #    plugin.redis.db = 1
    class Redis<Base
      class ThreadsafeQueue
        def initialize
          @queue = []
          @mutex = Mutex.new
          @cv =  ConditionVariable.new
        end

        def push(item)
          @mutex.synchronize do
            @queue.push(item)
          end

          @cv.signal
        end

        alias_method :<<, :push

        def pop
          @mutex.synchronize do
            while true
              if @queue.empty?
                begin
                  Timeout::timeout(5) do
                    @cv.wait(@mutex)
                  end
                rescue Timeout::Error
                  retry
                end
              else
                return @queue.shift
              end
            end
          end
        end
      end

      attr_reader :receiver_queue, :sender_queue

      def initialize
        @config = Config.instance
        @sources = []
        @subscribed = false
        @host = @config.pluginconf.fetch("redis.host", "localhost")
        @port = Integer(@config.pluginconf.fetch("redis.port", "6379"))
        @db = Integer(@config.pluginconf.fetch("redis.db", "1"))
      end

      def connect
        redis_opts = {:host => @host, :port => @port, :db => @db}

        Log.debug("Connecting to redis: %s" % redis_opts.inspect)

        @receiver_redis = ::Redis.new(redis_opts)
        @receiver_queue = ThreadsafeQueue.new
        @receiver_thread = nil

        @sender_redis = ::Redis.new(redis_opts)
        @sender_queue = ThreadsafeQueue.new
        @sender_thread = nil

        start_sender_thread
      end

      def subscribe(agent, type, collective)
        unless @subscribed
          if PluginManager["security_plugin"].initiated_by == :client
            @sources << "mcollective::reply::%s::%d" % [@config.identity, $$]
          else
            @config.collectives.each do |collective|
              @sources << "%s::server::direct::%s" % [collective, @config.identity]
              @sources << "%s::server::agents" % collective
            end
          end

          @subscribed = true
          start_receiver_thread(@sources)
        end
      end

      def unsubscribe(agent, type, collective); end
      def disconnect; end

      def receive
        msg = @receiver_queue.pop
        Message.new(msg[:body], msg, :headers => msg[:headers])
      end

      def publish(msg)
        Log.debug("About to publish to the sender queue")

        target = {:name => nil, :headers => {}, :name => nil}

        if msg.type == :direct_request
          msg.discovered_hosts.each do |node|
            target[:name] = "%s::server::direct::%s" % [msg.collective, node]
            target[:headers]["reply-to"] = "mcollective::reply::%s::%d" % [@config.identity, $$]

            Log.debug("Sending a direct message to Redis target '#{target[:name]}' with headers '#{target[:headers].inspect}'")

            @sender_queue << {:channel => target[:name],
                              :body => msg.payload,
                              :headers => target[:headers],
                              :command => :publish}
          end
        else
          if msg.type == :reply
            target[:name] = msg.request.headers["reply-to"]

          elsif msg.type == :request
            target[:name] = "%s::server::agents" % msg.collective
            target[:headers]["reply-to"] = "mcollective::reply::%s::%d" % [@config.identity, $$]
          end


          Log.debug("Sending a broadcast message to Redis target '#{target[:name]}' with headers '#{target[:headers].inspect}'")

          @sender_queue << {:channel => target[:name],
                            :body => msg.payload,
                            :headers => target[:headers],
                            :command => :publish}
        end
      end

      def start_receiver_thread(sources)
        @receiver_thread = Thread.new do
          begin
            @receiver_redis.subscribe(@sources) do |on|
              on.subscribe do |channel, subscriptions|
                Log.debug("Subscribed to %s" % channel)
              end

              on.message do |channel, message|
                begin
                  Log.debug("Got a message on %s: %s" % [channel, message])

                  @receiver_queue << YAML.load(message)
                rescue => e
                  Log.warn("Failed to receive from the receiver source: %s: %s" % [e.class, e.to_s])
                end
              end
            end
          rescue Exception => e
            Log.warn("The receiver thread lost connection to the Redis server: %s: %s" % [e.class, e.to_s])
            sleep 0.2
            retry
          end
        end

        Log.debug("Started receiver_thread %s" % @receiver_thread.inspect)
      end

      def start_sender_thread
        @sender_thread = Thread.new do
          Log.debug("Starting sender thread")

          loop do
            begin
              msg = @sender_queue.pop

              case msg[:command]
                when :publish
                  encoded = {:body => msg[:body], :headers => msg[:headers]}.to_yaml
                  @sender_redis.publish(msg[:channel], encoded)

                when :proc
                  msg[:proc].call(@sender_redis)
              end
            rescue Exception => e
              Log.warn("Could not publish message to redis: %s: %s" % [e.class, e.to_s])
              sleep 0.2
              retry
            end
          end
        end

        Log.debug("Started sender_thread %s" % @sender_thread.inspect)
      end
    end
  end
end
