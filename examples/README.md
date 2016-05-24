# MCollective Examples #

This directory contains example business-logic level Puppet configuration to
build a complete infrastructure for MCollective.

MCollective depends on a correctly configured middleware layer for operation.
Several middleware technologies are supported, most notably ActiveMQ or
RabbitMQ. It is outside the scope of the puppet/mcollective module to directly
manage those middleware services. The examples included in this directory show
how a site-specific profile might be built that leverages the
puppet/mcollective technology module in conjunction with other Puppet Labs
modules, puppetlabs/rabbitmq or puppetlabs/activemq, to build out a complete
technology stack.