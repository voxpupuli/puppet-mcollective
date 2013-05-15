module MCollective
  module Agent
    class Process<RPC::Agent
      activate_when do
        begin
          require 'sys/proctable'
          true
        rescue => e
          Log.warn('Cannot load sys/proctable gem. Process_agent plugin requires this gem to be installed')
          false
        end
      end

      action 'list' do
        pattern = request[:pattern] || '.'
        zombies = request[:just_zombies] || false

        reply[:pslist] = get_proc_list(pattern, zombies)
      end

      private
      def ps_to_hash(ps)
        require 'etc'
        result = {}

        ps.each_pair do |k,v|
          if k == :uid
            begin
              result[:username] = Etc.getpwuid(v).name
            rescue => e
              Log.debug("Could not get username for #{v}: #{e}")
              result[:username] = v
            end
          end

          result[k] = v
        end

        result
      end

      def get_proc_list(pattern, zombies)
        result = Sys::ProcTable.ps.map do |ps|
          ret = nil

          if ps['cmdline'] =~ /#{pattern}/
            if zombies
              ret = ps_to_hash(ps) if ps[:state] == 'Z'
            else
              ret = ps_to_hash(ps)
            end
          end

          ret
        end

        result.compact
      end
    end
  end
end
