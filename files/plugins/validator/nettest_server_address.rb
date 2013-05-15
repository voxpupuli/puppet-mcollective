module MCollective
  module Validator
    class Nettest_server_addressValidator
      def self.validate(server)
        Validator.typecheck(server, :string)
        Validator.validate(server, :shellsafe)

        (host, port) = server.split(":")

        raise ValidatorError, "The address '%s' must include both a hostname and port" % server unless host && port

        if !(host =~ /\A^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$\z/)
          raise ValidatorError, "The hostname '%s' is not a valid hostname" % host
        end

        if !(port =~ /\A\d+\Z/)
          raise ValidatorError, "The port '%s' is not a valid port" % port
        end
      end
    end
  end
end
