module MCollective
  module Util
    module NettestAgent
      require 'resolv'

      def self.is_hostname?(hostname)
        hostname =~ /\A^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9])$\z/
      end

      # Resolves hostname to an ip address.
      # If parameter is a ip address it will be returned unmodified
      # If the lookup fails nil is returned.
      def self.get_ip_from_hostname(hostname)
        if NettestAgent.is_hostname?(hostname)
          begin
            return Resolv.getaddress(hostname).to_s
          rescue Resolv::ResolvError
            return nil
          end
        else
          return hostname
        end
      end
    end
  end
end
