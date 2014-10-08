require 'spec_helper'

describe 'mcollective' do
  it { should contain_class('mcollective') }
  it { should_not contain_class('mcollective::client') }
  it { should_not contain_class('mcollective::middleware') }

  describe '#server' do
    context 'default (true)' do
      it { should contain_class('mcollective::server') }
    end

    context 'false' do
      let(:params) { { :server => false } }
      it { should_not contain_class('mcollective::server') }
    end
  end

  context 'installing a server' do
    describe '#manage_packages' do
      context 'true' do
        let(:params) { { :server => true, :manage_packages => true } }
        it { should contain_package('mcollective') }
      end

      context 'false' do
        let(:params) { { :server => true, :manage_packages => false } }
        it { should_not contain_package('mcollective') }
      end
    end

    describe '#version' do
      it 'should default to present' do
        should contain_package('mcollective').with_ensure('present')
      end

      context '42' do
        let(:params) { { :version => '42' } }
        it { should contain_package('mcollective').with_ensure('42') }
      end
    end

    describe '#ruby_stomp_ensure' do
      let(:facts) { { :osfamily => 'Debian' } }
      it 'should default to installed' do
        should contain_package('ruby-stomp').with_ensure('installed')
      end
      
      context 'latest' do
        let(:params) { { :ruby_stomp_ensure => 'latest' } }
        it { should contain_package('ruby-stomp').with_ensure('latest') }
      end

      context '1.2.10-1puppetlabs1' do
        let(:params) { { :ruby_stomp_ensure => '1.2.10-1puppetlabs1' } }
        it { should contain_package('ruby-stomp').with_ensure('1.2.10-1puppetlabs1') }
      end
    end

    describe '#main_collective' do
      context 'default' do
        it { should contain_mcollective__common__setting('main_collective').with_value('mcollective') }
      end

      context 'set' do
        let(:params) { { :main_collective => 'bob' } }
        it { should contain_mcollective__common__setting('main_collective').with_value('bob') }
      end
    end

    describe '#collectives' do
      context 'default' do
        it { should contain_mcollective__common__setting('collectives').with_value('mcollective') }
      end

      context 'set' do
        let(:params) { { :collectives => 'henry' } }
        it { should contain_mcollective__common__setting('collectives').with_value('henry') }
      end
    end

    describe '#server_config_file' do
      it 'should default to /etc/mcollective/server.cfg' do
        should contain_file('mcollective::server').with_path('/etc/mcollective/server.cfg')
      end

      context '/foo' do
        let(:params) { { :server_config_file => '/foo' } }
        it { should contain_file('mcollective::server').with_path('/foo') }
      end
    end

    describe '#server_logfile' do
      it 'should default to /var/log/mcollective.log' do
        should contain_mcollective__server__setting('logfile').with_value('/var/log/mcollective.log')
      end

      context '/tmp/log' do
        let(:params) { { :server_logfile => '/tmp/log' } }
        it { should contain_mcollective__server__setting('logfile').with_value('/tmp/log') }
      end
    end

    describe '#server_loglevel' do
      it 'should default to info' do
        should contain_mcollective__server__setting('loglevel').with_value('info')
      end

      context 'debug' do
        let(:params) { { :server_loglevel => 'debug' } }
        it { should contain_mcollective__server__setting('loglevel').with_value('debug') }
      end
    end

    describe '#server_daemonize' do
      it 'should default to 1' do
        should contain_mcollective__server__setting('daemonize').with_value('1')
      end

      context '0' do
        let(:params) { { :server_daemonize => '0' } }
        it { should contain_mcollective__server__setting('daemonize').with_value('0') }
      end
    end

    describe '#factsource' do
      it 'should default to yaml' do
        should contain_mcollective__server__setting('factsource').with_value('yaml')
      end

      context 'yaml' do
        let(:facts) { { :osfamily => 'RedHat', :number_of_cores => '42', :non_string => 69 } }

        describe '#yaml_fact_path' do
          context 'default' do
            it 'should default to /etc/mcollective/facts.yaml' do
              should contain_mcollective__server__setting('plugin.yaml').with_value('/etc/mcollective/facts.yaml')
            end
            it { should contain_file('/usr/libexec/mcollective/refresh-mcollective-metadata').with_content(/File.rename\('\/etc\/mcollective\/facts.yaml.new', '\/etc\/mcollective\/facts.yaml'\)/) }
          end
          
          context '/tmp/facts' do
            let(:params) { { :yaml_fact_path => '/tmp/facts' } }
            it { should contain_mcollective__server__setting('plugin.yaml').with_value('/tmp/facts') }
            it { should contain_file('/usr/libexec/mcollective/refresh-mcollective-metadata').with_content(/File.rename\('\/tmp\/facts.new', '\/tmp\/facts'\)/) }
          end
        end
      end

      context 'facter' do
        let(:params) { { :server => true, :factsource => 'facter' } }
        it { should contain_mcollective__server__setting('factsource').with_value('facter') }
        it { should contain_mcollective__server__setting('fact_cache_time').with_value('300') }
        it { should contain_package('mcollective-facter-facts') }
      end
    end

    describe '#connector' do
      it 'should default to activemq' do
        should contain_mcollective__common__setting('connector').with_value('activemq')
      end

      context 'activemq' do
        describe '#middleware_hosts' do
          let(:params) { { :server => true, :middleware_hosts => %w{ foo bar } } }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.size').with_value(2) }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.1.host').with_value('foo') }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.1.port').with_value('61613') }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.2.host').with_value('bar') }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.2.port').with_value('61613') }
        end

        describe '#middleware_user' do
          let(:params) { { :server => true, :middleware_hosts => %w{ foo } } }
          it 'should default to mcollective' do
            should contain_mcollective__common__setting('plugin.activemq.pool.1.user').with_value('mcollective')
          end

          context 'bob' do
            let(:params) { { :server => true, :middleware_hosts => %w{ foo }, :middleware_user => 'bob' } }
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.user').with_value('bob') }
          end
        end

        describe '#middleware_password' do
          let(:params) { { :server => true, :middleware_hosts => %w{ foo } } }
          it 'should default to marionette' do
            should contain_mcollective__common__setting('plugin.activemq.pool.1.password').with_value('marionette')
          end

          context 'bob' do
            let(:params) { { :server => true, :middleware_hosts => %w{ foo }, :middleware_password => 'bob' } }
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.password').with_value('bob') }
          end
        end

        describe '#middleware_ssl' do
          let(:params) { { :server => true, :middleware_hosts => %w{ foo } } }
          context 'default' do
            it { should_not contain_mcollective__common__setting('plugin.activemq.pool.1.ssl') }
            it { should_not contain_file('/etc/mcollective/ca.pem') }
            it { should_not contain_file('/etc/mcollective/server_public.pem') }
            it { should_not contain_file('/etc/mcollective/server_private.pem') }
          end

          context 'true' do
            let(:common_params) { { :server => true, :middleware_hosts => %w{ foo }, :middleware_ssl => true } }
            let(:params) { common_params }
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.ssl').with_value('1') }
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.ssl.fallback').with_value('0') }

            describe '#ssl_ca_cert' do
              context 'set' do
                let(:params) { common_params.merge({ :ssl_ca_cert => 'puppet:///modules/foo/ca_cert.pem' }) }
                it { should contain_file('/etc/mcollective/ca.pem').with_source('puppet:///modules/foo/ca_cert.pem') }
              end
            end

            describe '#ssl_server_public' do
              context 'set' do
                let(:params) { common_params.merge({ :ssl_server_public => 'puppet:///modules/foo/server_public.pem' }) }
                it { should contain_file('/etc/mcollective/server_public.pem').with_source('puppet:///modules/foo/server_public.pem') }
              end
            end

            describe '#ssl_server_private' do
              context 'set' do
                let(:params) { common_params.merge({ :ssl_server_private => 'puppet:///modules/foo/server_private.pem' }) }
                it { should contain_file('/etc/mcollective/server_private.pem').with_source('puppet:///modules/foo/server_private.pem') }
              end
            end

            describe '#ssl_server_fallback' do
              context 'set' do
                let(:params) { common_params.merge({ :middleware_ssl_fallback => true }) }
                it { should contain_mcollective__common__setting('plugin.activemq.pool.1.ssl.fallback').with_value('1') }
              end
            end
          end
        end

        describe '#middleware_port' do
          let(:common_params) { { :server => true, :middleware_hosts => %w[ foo ] }}
          let(:params) { common_params }
          context 'default' do
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.port').with_value('61613') }
          end

          context 'set' do
            let(:params) { common_params.merge({ :middleware_port => '1701' }) }
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.port').with_value('1701') }
          end
        end

        describe '#middleware_ssl_port' do
          let(:common_params) { { :server => true, :middleware_hosts => %w[ foo ], :middleware_ssl => true }}
          let(:params) { common_params }
          context 'default' do
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.port').with_value('61614') }
          end

          context 'set' do
            let(:params) { common_params.merge({ :middleware_ssl_port => '1702' }) }
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.port').with_value('1702') }
          end
        end
      end

      context 'rabbitmq' do
        let(:common_params) { { :server => true, :connector => 'rabbitmq' } }
        let(:params) { common_params }
        describe '#rabbitmq_vhost' do
          context 'default' do
            it { should contain_mcollective__common__setting('plugin.rabbitmq.vhost').with_value('/mcollective') }
          end

          context 'set' do
            let(:params) { common_params.merge({ :rabbitmq_vhost => '/pies' }) }
            it { should contain_mcollective__common__setting('plugin.rabbitmq.vhost').with_value('/pies') }
          end
        end
      end
    end

    describe '#securityprovider' do
      it 'should default to psk' do
        should contain_mcollective__common__setting('securityprovider').with_value('psk')
      end

      context 'ssl' do
        let(:params) { { :server => true, :securityprovider => 'ssl' } }
        it { should contain_mcollective__server__setting('plugin.ssl_server_public').with_value('/etc/mcollective/server_public.pem') }
        it { should contain_file('/etc/mcollective/server_public.pem') }

        describe '#ssl_client_certs' do
          it { should contain_file('/etc/mcollective/clients') }

          context 'default' do
            it { should contain_file('/etc/mcollective/clients').with_source('puppet:///modules/mcollective/empty') }
          end

          context 'set' do
            let(:params) { { :server => true, :securityprovider => 'ssl', :ssl_client_certs => 'puppet:///modules/foo/clients' } }
            it { should contain_file('/etc/mcollective/clients').with_source('puppet:///modules/foo/clients') }
          end
        end
      end

      context 'psk' do
        let(:params) { { :server => true, :securityprovider => 'psk' } }
        it { should contain_mcollective__common__setting('securityprovider').with_value('psk') }
        it { should contain_mcollective__common__setting('plugin.psk').with_value('changemeplease') }
      end
    end

    describe '#rpcauthprovider' do
      it 'should default to action_policy' do
        should contain_mcollective__server__setting('rpcauthprovider').with_value('action_policy')
      end

      context 'action_policy' do
        let(:params) { { :server => true, :rpcauthprovider => 'action_policy' } }
        it { should contain_mcollective__server__setting('plugin.actionpolicy.allow_unconfigured').with_value('1') }
      end
    end

    describe '#rpcauditprovider' do
      it 'should default to logfile' do
        should contain_mcollective__server__setting('rpcauditprovider').with_value('logfile')
      end

      context 'logfile' do
        let(:params) { { :server => true, :rpcauditprovider => 'logfile' } }
        it { should contain_mcollective__server__setting('plugin.rpcaudit.logfile').with_value('/var/log/mcollective-audit.log') }
      end
    end

    describe '#classesfile' do
      it 'should default to /var/lib/puppet/state/classes.txt' do
        should contain_mcollective__server__setting('classesfile').with_value('/var/lib/puppet/state/classes.txt')
      end

      context '/tmp/classes.txt' do
        let(:params) { { :server => true, :classesfile => '/tmp/classes.txt' } }
        it { should contain_mcollective__server__setting('classesfile').with_value('/tmp/classes.txt') }
      end
    end

    describe '#core_libdir' do
      context 'default' do
        it { should contain_mcollective__common__setting('libdir').with_value('/usr/local/libexec/mcollective:/usr/libexec/mcollective') }
      end

      context 'set' do
        let(:params) { { :core_libdir => '/usr/libexec/fishy/fishy' } }
        it { should contain_mcollective__common__setting('libdir').with_value('/usr/local/libexec/mcollective:/usr/libexec/fishy/fishy') }
      end
    end

    describe '#site_libdir' do
      context 'default' do
        it { should contain_file('/usr/local/libexec/mcollective') }
        it { should contain_mcollective__common__setting('libdir').with_value('/usr/local/libexec/mcollective:/usr/libexec/mcollective') }
      end

      context 'set' do
        let(:params) { { :site_libdir => '/usr/local/fishy/fishy' } }
        it { should contain_file('/usr/local/fishy/fishy') }
        it { should contain_mcollective__common__setting('libdir').with_value('/usr/local/fishy/fishy:/usr/libexec/mcollective') }
      end
    end

    describe '#registration' do
      it 'should default to undef' do
        should_not contain_mcollective__server__setting('registration')
      end

      context 'redis' do
        let(:params) { { :server => true, :registration => 'redis' } }
        it { should contain_mcollective__server__setting('registration').with_value('redis') }
      end
    end
  end

  describe '#client' do
    context 'true' do
      let(:params) { { :client => true } }
      it { should contain_class('mcollective::client') }
    end

    context 'false' do
      let(:params) { { :client => false } }
      it { should_not contain_class('mcollective::client') }
    end
  end

  describe 'installing a client' do
    let(:params) { { :server => false, :client => true } }

    describe '#manage_packages' do
      context 'true' do
        let(:params) { { :client => true, :manage_packages => true } }
        it { should contain_package('mcollective-client') }
      end

      context 'false' do
        let(:params) { { :client => true, :manage_packages => false } }
        it { should_not contain_package('mcollective-client') }
      end
    end

    describe '#version' do
      it 'should default to present' do
        should contain_package('mcollective-client').with_ensure('present')
      end

      context '42' do
        let(:params) { { :client => true, :version => '42' } }
        it { should contain_package('mcollective-client').with_ensure('42') }
      end
    end

    describe '#client_config_file' do
      it 'should default to /etc/mcollective/client.cfg' do
        should contain_file('mcollective::client').with_path('/etc/mcollective/client.cfg')
      end

      context '/foo' do
        let(:params) { { :client => true, :client_config_file => '/foo' } }
        it { should contain_file('mcollective::client').with_path('/foo') }
      end
    end

    describe '#connector' do
      it 'should default to activemq' do
        should contain_mcollective__common__setting('connector').with_value('activemq')
      end

      context 'activemq' do
        describe '#middleware_hosts' do
          let(:params) { { :server => false, :client => true, :middleware_hosts => %w{ foo bar } } }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.size').with_value(2) }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.1.host').with_value('foo') }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.1.port').with_value('61613') }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.2.host').with_value('bar') }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.2.port').with_value('61613') }
        end

        describe '#middleware_user' do
          let(:params) { { :server => false, :client => true, :middleware_hosts => %w{ foo } } }
          it 'should default to mcollective' do
            should contain_mcollective__common__setting('plugin.activemq.pool.1.user').with_value('mcollective')
          end

          context 'bob' do
            let(:params) { { :server => false, :client => true, :middleware_hosts => %w{ foo }, :middleware_user => 'bob' } }
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.user').with_value('bob') }
          end
        end

        describe '#middleware_password' do
          let(:params) { { :server => false, :client => true, :middleware_hosts => %w{ foo } } }
          it 'should default to marionette' do
            should contain_mcollective__common__setting('plugin.activemq.pool.1.password').with_value('marionette')
          end

          context 'bob' do
            let(:params) { { :server => false, :client => true, :middleware_hosts => %w{ foo }, :middleware_password => 'bob' } }
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.password').with_value('bob') }
          end
        end

        describe '#middleware_ssl' do
          let(:params) { { :server => false, :client => true, :middleware_hosts => %w{ foo } } }
          it 'should default to false' do
            should_not contain_mcollective__common__setting('plugin.activemq.pool.1.ssl')
          end

          context 'true' do
            let(:params) { { :server => false, :client => true, :middleware_hosts => %w{ foo }, :middleware_ssl => true } }
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.ssl').with_value('1') }
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.ssl.fallback').with_value('0') }

            describe '#ssl_server_fallback' do
              context 'set' do
                let(:params) { { :server => false, :client => true, :middleware_hosts => %w{ foo }, :middleware_ssl => true, :middleware_ssl_fallback => true } }
                it { should contain_mcollective__common__setting('plugin.activemq.pool.1.ssl.fallback').with_value('1') }
              end
            end
          end
        end
      end

      describe '#securityprovider' do
        context 'ssl' do
          let(:params) { { :server => false, :client => true, :securityprovider => 'ssl' } }
          it { should contain_file('mcollective::client').with_ensure('absent') }
        end

        context 'psk' do
          let(:params) { { :server => false, :client => true, :securityprovider => 'psk' } }
          it { should contain_file('mcollective::client').with_content(/datacat/) }
        end
      end
    end

    describe '#securityprovider' do
      it 'should default to psk' do
        should contain_mcollective__common__setting('securityprovider').with_value('psk')
      end

      context 'ssl' do
        let(:params) { { :server => true, :securityprovider => 'ssl' } }
        it { should contain_mcollective__server__setting('plugin.ssl_server_public').with_value('/etc/mcollective/server_public.pem') }
        it { should contain_file('/etc/mcollective/server_public.pem') }
      end

      context 'psk' do
        let(:params) { { :server => true, :securityprovider => 'psk' } }
        it { should contain_mcollective__common__setting('securityprovider').with_value('psk') }
        it { should contain_mcollective__common__setting('plugin.psk').with_value('changemeplease') }
      end
    end
  end
end
