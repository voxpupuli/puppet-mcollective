module MCollective
  module Util
    class ActionPolicy
      attr_accessor :config, :allow_unconfigured, :configdir, :agent, :caller, :action

      def self.authorize(request)
        ActionPolicy.new(request).authorize_request
      end

      def initialize(request)
        @config = Config.instance
        @agent = request.agent
        @caller = request.caller
        @action = request.action
        @allow_unconfigured = !!(config.pluginconf.fetch('actionpolicy.allow_unconfigured', 'n') =~ /^1|y/i)
        @configdir = @config.configdir
      end

      def authorize_request
        # Lookup the policy file. If none exists and @allow_unconfigured
        # is false the request gets denied.
        policy_file = lookup_policy_file

        # No policy file exists and allow_unconfigured is false
        if !policy_file && !@allow_unconfigured
          deny('Could not load any valid policy files. Denying based on allow_unconfigured: %s' % @allow_unconfigured)
        # No policy exists but allow_unconfigured is true
        elsif !(policy_file) && @allow_unconfigured
          Log.debug('Could not load any valid policy files. Allowing based on allow_unconfigured: %s' % @allow_unconfigured)
          return true
        end

        # A policy file exists
        parse_policy_file(policy_file)
      end

      def parse_policy_file(policy_file)
        Log.debug('Parsing policyfile for %s: %s' % [@agent, policy_file])
        allow = @allow_unconfigured

        File.read(policy_file).each_line do |line|
          next if line =~ /^(#.*|\s*)$/

          if line =~ /^policy\s+default\s+(\w+)/
            if $1 == 'allow'
              allow = true
            else
              allow = false
            end
          elsif line =~ /^(allow|deny)\t+(.+?)\t+(.+?)\t+(.+?)(\t+(.+?))*$/
            if check_policy($2, $3, $4, $6)
              if $1 == 'allow'
                return true
              else
                deny("Denying based on explicit 'deny' policy rule in policyfile: %s" % File.basename(policy_file))
              end
            end
          else
            Log.debug("Cannot parse policy line: %s" % line)
          end
        end

        allow || deny("Denying based on default policy in %s" % File.basename(policy_file))
      end

      # Check if a request made by a caller matches the state defined in the policy
      def check_policy(rpccaller, actions, facts, classes)
        # If we have a wildcard caller or the caller matches our policy line
        # then continue else skip this policy line\
        if (rpccaller != '*') && (rpccaller != @caller)
          return false
        end

        # If we have a wildcard actions list or the request action is in the list
        # of actions in the policy line continue, else skip this policy line
        if (actions != '*') && !(actions.split.include?(@action))
          return false
        end

        unless classes
          return parse_compound(facts)
        else
          return parse_facts(facts) && parse_classes(classes)
        end
      end

      def parse_facts(facts)
        return true if facts == '*'

        if is_compound?(facts)
          return parse_compound(facts)
        else
          facts.split.each do |fact|
            return false unless lookup_fact(fact)
          end
        end

        true
      end

      def parse_classes(classes)
        return true if classes == '*'

        if is_compound?(classes)
          return parse_compound(classes)
        else
          classes.split.each do |klass|
            return false unless lookup_class(klass)
          end
        end

        true
      end

      def lookup_fact(fact)
        if fact =~ /(.+)(<|>|=|<=|>=)(.+)/
          lv = $1
          sym = $2
          rv = $3

          sym = '==' if sym == '='
          return eval("'#{Util.get_fact(lv)}'#{sym}'#{rv}'")
        else
          Log.warn("Class found where fact was expected")
          return false
        end
      end

      def lookup_class(klass)
        if klass =~ /(.+)(<|>|=|<=|>=)(.+)/
          Log.warn("Fact found where class was expected")
          return false
        else
          return Util.has_cf_class?(klass)
        end
      end

      def lookup(token)
        if token =~  /(.+)(<|>|=|<=|>=)(.+)/
          return lookup_fact(token)
        else
          return lookup_class(token)
        end
      end

      # Here we lookup the full path of the policy file. If the policyfile
      # does not exist, we check to see if a default file was set and
      # determine its full path. If no default file exists, or default was
      # not specified, we return false.
      def lookup_policy_file
        policy_file = File.join(@configdir, "policies", "#{@agent}.policy")

        Log.debug("Looking for policy in #{policy_file}")

        return policy_file if File.exist?(policy_file)

        if @config.pluginconf.fetch('actionpolicy.enable_default', 'n') =~ /^1|y/i
          defaultname = @config.pluginconf.fetch('actionpolicy.default_name', 'default')
          default_file = File.join(@configdir, "policies", "#{defaultname}.policy")

          Log.debug("Initial lookup failed: looking for policy in #{default_file}")

          return default_file if File.exist?(default_file)
        end

        Log.debug('Could not find any policy files.')
        nil
      end

      # Evalute a compound statement and return its truth value
      def eval_statement(statement)
        token_type = statement.keys.first
        token_value = statement.values.first

        return token_value if (token_type != 'statement' && token_type != 'fstatement')

        if token_type == 'statement'
            return lookup(token_value)
        elsif token_type == 'fstatement'
          begin
            return Matcher.eval_compound_fstatement(token_value)
          rescue => e
            Log.warn("Could not call Data function in policy file: #{e}")
            return false
          end
        end
      end

      def is_compound?(list)
        list.split.each do |token|
          if token =~ /^!|^not$|^or$|^and$|\(.+\)/
            return true
          end
        end

        false
      end

      def parse_compound(list)
        stack = Matcher.create_compound_callstack(list)

        begin
          stack.map!{ |item| eval_statement(item) }
        rescue => e
          Log.debug(e.to_s)
          return false
        end

        eval(stack.join(' '))
      end

      def deny(logline)
        Log.debug(logline)

        raise(RPCAborted, 'You are not authorized to call this agent or action.')
      end
    end
  end
end
