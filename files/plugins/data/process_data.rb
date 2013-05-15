module MCollective
  module Data
    class Process_data<Base

      #Activate if the sys-proctable gem has been installed
      activate_when do
        begin
          require 'sys/proctable'
          true
        rescue LoadError
          Log.warn('Cannot load Process_data plugin. Process_data plugin requires this gem to be installed.')
          false
        end
      end

      query do |pattern|
        result[:exists] = false
        Sys::ProcTable.ps.map do |ps|
          if ps['cmdline'] =~ /#{pattern}/
            result[:exists] = true
            break
          end
        end
      end
    end
  end
end
