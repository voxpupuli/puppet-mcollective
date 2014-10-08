#!/usr/bin/env ruby
# vim: set sw=2 sts=2 et tw=80 :
Puppet::Parser::Functions.newfunction(:mco_array_to_string, :type => :rvalue) do |args|
  if ! args[0].is_a? Array
    raise ArgumentError, "Expected an array, but got a #{args[0].class}"
  end

  args[0].collect do |elem|
    elem.to_s
  end
end
