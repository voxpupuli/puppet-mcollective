# Class: mcollective::server::middleware::rabbitmq
#
#	This class installs the RabbitMQ server package and all dependencies as well
#	as configures it for use with MCollective.
#
# Parameters:
#
#	[*version*]			- The version of the MCollective package(s) to be installed.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mcollective::server::middleware::rabbitmq (
	$package_name		= 'rabbitmq-server',
	$package_version	= '2.8.7-1',
	$delete_guest_user	= true,
	$mcollective_vhost	= '/mcollective',
	$mcollective_user	= 'mcollective',
	$mcollective_pass	= 'UNSET',
	$collectives		= [ 'mcollective' ]
) {

	package { 'eventmachine' :
		ensure		=> installed,
		provider	=> 'gem'
	}

	package { 'amqp' :
		ensure		=> installed,
		provider	=> 'gem',
		require		=> Package['eventmachine']
	}

	class { 'rabbitmq::server' :
		package_name		=> $package_name,
		version				=> $package_version,
		config_stomp		=> true,
		delete_guest_user	=> $delete_guest_user,
		require				=> Package['amqp']
	}

	rabbitmq_plugin {'rabbitmq_stomp':
		ensure		=> present,
		provider	=> 'rabbitmqplugins',
		require		=> Package[$package_name]
	}

	rabbitmq_vhost { $mcollective_vhost:
		ensure		=> present,
		provider	=> 'rabbitmqctl',
		require		=> Package[$package_name]
	}

	rabbitmq_user { $mcollective_user:
		admin		=> false,
		password	=> $mcollective_pass,
		provider	=> 'rabbitmqctl',
		require		=> Package[$package_name]
	}

	rabbitmq_user_permissions { "${mcollective_user}@${mcollective_vhost}":
		configure_permission	=> '.*',
		read_permission			=> '.*',
		write_permission		=> '.*',
		provider				=> 'rabbitmqctl',
		require					=> [ Rabbitmq_vhost[$mcollective_vhost], Rabbitmq_user[$mcollective_user] ]
	}

	# Create required excahnges for each collective
	define exchanges ( $collective = $title, $mcollective_user, $mcollective_pass, $mcollective_vhost ) {
		rabbitmq_exchange { "${collective}_broadcast@${mcollective_vhost}" :
			exchange_type	=> topic,
			user			=> $mcollective_user,
			password		=> $mcollective_pass,
			provider		=> 'amqp',
			require			=> Rabbitmq_user_permissions["${mcollective_user}@${mcollective_vhost}"]
		}

		rabbitmq_exchange { "${collective}_directed@${mcollective_vhost}" :
			exchange_type	=> direct,
			user			=> $mcollective_user,
			password		=> $mcollective_pass,
			provider		=> 'amqp',
			require			=> Rabbitmq_user_permissions["${mcollective_user}@${mcollective_vhost}"]
		}
	}

	exchanges { $collectives :
		mcollective_user	=> $mcollective_user,
		mcollective_vhost	=> $mcollective_vhost,
		mcollective_pass	=> $mcollective_pass
	}

}