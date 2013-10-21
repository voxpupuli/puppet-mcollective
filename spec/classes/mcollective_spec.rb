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
        it { should contain_file('/etc/mcollective/facts.yaml') }
        it { should contain_file('/etc/mcollective/facts.yaml').with_content(/^  osfamily: RedHat/) }
        it { should contain_file('/etc/mcollective/facts.yaml').with_content(/^  number_of_cores: "42"/) }
        it 'should be alpha-sorted' do
          should contain_file('/etc/mcollective/facts.yaml').with_content(/^  number_of_cores:.*?^  osfamily: RedHat$/m)
        end
        it 'should not leak' do
          should_not contain_file('/etc/mcollective/facts.yaml').with_content(/middleware_password/)
        end

        context 'dynamic fact removal' do
          let(:facts) do
            {
              :last_run       => 'Wed Oct 16 10:16:10 MST 2013',
              :memoryfree     => '5.78 GB',
              :memoryfree_mb  => '5915.74',
              :rubysitedir    => '/usr/lib/ruby/site_ruby/1.8',
              :swapfree       => '2.00 GB',
              :swapfree_mb    => '2047.99',
              :uptime         => '16:20 hours',
              :uptime_days    => '0',
              :uptime_hours   => '16',
              :uptime_seconds => '58838',
            }
          end

          it { should contain_file('/etc/mcollective/facts.yaml') }
          it do
            facts.keys.each do |k|
              should_not contain_file('/etc/mcollective/facts.yaml').with_content(/^#{k.to_s}.*/m)
            end
          end
        end

        describe '#yaml_fact_path' do
          it 'should default to /etc/mcollective/facts.yaml' do
            should contain_mcollective__server__setting('plugin.yaml').with_value('/etc/mcollective/facts.yaml')
          end

          context '/tmp/facts' do
            let(:params) { { :yaml_fact_path => '/tmp/facts' } }
            it { should contain_file('/tmp/facts') }
            it { should contain_mcollective__server__setting('plugin.yaml').with_value('/tmp/facts') }
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

  describe '#middleware' do
    context 'true' do
      let(:params) { { :middleware => true } }
      it { should contain_class('mcollective::middleware') }
    end

    context 'false' do
      let(:params) { { :middleware => false } }
      it { should_not contain_class('mcollective::middleware') }
    end
  end

  describe 'installing middleware' do
    let(:params) { { :server => false, :middleware => true } }
    it { should contain_class('mcollective::middleware') }

    describe '#connector' do
      it 'should default to apache' do
        should contain_class('mcollective::middleware::activemq')
      end

      context 'activemq' do
        it { should contain_class('activemq') }
        it { should contain_class('activemq').with_instance('mcollective') }

        describe '#activemq_confdir' do
          let(:common_params) { { :server => false, :middleware => true,  :middleware_ssl => true } }
          let(:params) { common_params }
          context 'default (/etc/activemq)' do
            it { should contain_file('/etc/activemq/ca.pem') }
          end

          context 'set' do
            let(:params) { common_params.merge({ :activemq_confdir => '/etc/special' }) }
            it { should contain_file('/etc/special/ca.pem') }
          end
        end

        describe '#activemq_console' do
          context 'default (false)' do
            it { should contain_file('activemq.xml').with_content(/(?!:jetty)/) }
          end

          context 'true' do
            let(:params) { { :server => false, :middleware => true, :activemq_console => true }}
            it { should contain_file('activemq.xml').with_content(/jetty/) }
          end
        end

        describe '#middleware_ssl' do
          it 'should default to false' do
            should_not contain_java_ks('mcollective:truststore')
          end

          context 'true' do
            let(:params) { { :middleware => true, :middleware_ssl => true } }
            it { should contain_java_ks('mcollective:truststore').with_password('puppet') }
          end
        end

        describe '#activemq_template' do
          context 'default (in-module)' do
            let(:params) { { :middleware => true } }
            it { should contain_file('activemq.xml').with_content(/middleware/) }
          end

          context 'set' do
            let(:params) { { :middleware => true, :activemq_template => 'site_mcollective/test_activemq.xml.erb' } }
            it { should contain_file('activemq.xml').with_content(/^Test of the mcollective::activemq_template parameter/) }
          end
        end

        describe '#activemq_config' do
          context 'default (use template in-module)' do
            let(:params) { { :middleware => true } }
            it { should contain_file('activemq.xml').with_content(/middleware/) }
          end

          context 'set' do
            let(:params) { { :middleware => true, :activemq_config => 'Lovingly hand-crafted' } }
            it { should contain_file('activemq.xml').with_content('Lovingly hand-crafted') }
          end
        end

        describe '#middleware_user' do
          let(:params) { { :server => false, :middleware => true } }
          it 'should default to mcollective' do
            should contain_file('activemq.xml').with_content(/authenticationUser username="mcollective"/)
          end

          context 'bob' do
            let(:params) { { :server => false, :middleware => true, :middleware_user => 'bob' } }
            it { should contain_file('activemq.xml').with_content(/authenticationUser username="bob"/) }
          end
        end

        describe '#middleware_password' do
          let(:params) { { :server => false, :middleware => true } }
          it 'should default to marionette' do
            should contain_file('activemq.xml').with_content(/authenticationUser username="mcollective" password="marionette"/)
          end

          context 'thereichangedit' do
            let(:params) { { :server => false, :middleware => true, :middleware_password => 'thereichangedit' } }
            it { should contain_file('activemq.xml').with_content(/authenticationUser username="mcollective" password="thereichangedit"/) }
          end
        end

        describe '#middleware_admin_user' do
          let(:params) { { :server => false, :middleware => true } }
          it 'should default to admin' do
            should contain_file('activemq.xml').with_content(/authenticationUser username="admin"/)
          end

          context 'bob' do
            let(:params) { { :server => false, :middleware => true, :middleware_admin_user => 'bob' } }
            it { should contain_file('activemq.xml').with_content(/authenticationUser username="bob"/) }
          end
        end

        describe '#middleware_admin_password' do
          let(:params) { { :server => false, :middleware => true } }
          it 'should default to secret' do
            should contain_file('activemq.xml').with_content(/authenticationUser username="admin" password="secret"/)
          end

          context 'thereichangedit' do
            let(:params) { { :server => false, :middleware => true, :middleware_admin_password => 'thereichangedit' } }
            it { should contain_file('activemq.xml').with_content(/authenticationUser username="admin" password="thereichangedit"/) }
          end
        end

        describe '#middleware_ssl' do
          let(:params) { { :server => false, :middleware => true } }
          it 'should default to false' do
            should contain_file('activemq.xml').with_content(/transportConnector name="stomp" uri="stomp:/)
          end

          context 'false' do
            it { should_not contain_file('/etc/activemq/ca.pem') }
            it { should_not contain_file('/etc/activemq/server_public.pem') }
            it { should_not contain_file('/etc/activemq/server_private.pem') }
          end

          context 'true' do
            let(:common_params) { { :server => false, :middleware => true, :middleware_ssl => true } }
            let(:params) { common_params }
            it { should contain_file('activemq.xml').with_content(/transportConnector name="stomp\+ssl" uri="stomp\+ssl:/) }

            describe '#ssl_ca_cert' do
              context 'set' do
                let(:params) { common_params.merge({ :ssl_ca_cert => 'puppet:///modules/foo/ca_cert.pem' }) }
                it { should contain_file('/etc/activemq/ca.pem').with_source('puppet:///modules/foo/ca_cert.pem') }
              end
            end

            describe '#ssl_server_public' do
              context 'set' do
                let(:params) { common_params.merge({ :ssl_server_public => 'puppet:///modules/foo/server_public.pem' }) }
                it { should contain_file('/etc/activemq/server_public.pem').with_source('puppet:///modules/foo/server_public.pem') }
              end
            end

            describe '#ssl_server_private' do
              context 'set' do
                let(:params) { common_params.merge({ :ssl_server_private => 'puppet:///modules/foo/server_private.pem' }) }
                it { should contain_file('/etc/activemq/server_private.pem').with_source('puppet:///modules/foo/server_private.pem') }
              end
            end
          end
        end

        describe '#middleware_port' do
          let(:common_params) { { :server => false, :middleware => true } }
          let(:params) { common_params }
          context 'default' do
            it { should contain_file('activemq.xml').with_content(/transportConnector name="stomp" uri="stomp:.*?:61613"/) }
          end

          context 'set' do
            let(:params) { common_params.merge({ :middleware_port => '1701' }) }
            it { should contain_file('activemq.xml').with_content(/transportConnector name="stomp" uri="stomp:.*?:1701"/) }
          end
        end

        describe '#middleware_ssl_port' do
          let(:common_params) { { :server => true, :middleware => true, :middleware_ssl => true }}
          let(:params) { common_params }
          context 'default' do
            it { should contain_file('activemq.xml').with_content(/transportConnector name="stomp\+ssl" uri="stomp\+ssl:.*?:61614\?/) }
          end

          context 'set' do
            let(:params) { common_params.merge({ :middleware_ssl_port => '1702' }) }
            it { should contain_file('activemq.xml').with_content(/transportConnector name="stomp\+ssl" uri="stomp\+ssl:.*?:1702\?/) }
          end
        end
      end

      context 'rabbitmq' do
        let(:facts) { { :osfamily => 'RedHat' } }
        let(:common_params) { { :server => false, :middleware => true, :connector => 'rabbitmq' } }
        let(:params) { common_params }
        it { should contain_class('rabbitmq') }

        describe '#delete_guest_user' do
          context 'default (false)' do
            it { should contain_class('rabbitmq').with_delete_guest_user(false) }
          end

          context 'true' do
            let(:params) { common_params.merge({ :delete_guest_user => true }) }
            it { should contain_class('rabbitmq').with_delete_guest_user(true) }
          end
        end

        describe '#middleware_ssl' do
          context 'false' do
            let(:params) { common_params.merge({ :middleware_ssl => false }) }
            it { should_not contain_file('/etc/rabbitmq/ca.pem') }
          end

          context 'true' do
            let(:params) { common_params.merge({ :middleware_ssl => true }) }

            describe '#rabbitmq_confdir' do
              context 'default' do
                it { should contain_file('/etc/rabbitmq/ca.pem') }
              end

              context 'set' do
                let(:params) { common_params.merge({ :middleware_ssl => true, :rabbitmq_confdir => '/etc/special' }) }
                it { should contain_file('/etc/special/ca.pem') }
              end
            end
          end
        end

        describe '#rabbitmq_vhost' do
          context 'default' do
            it { should contain_rabbitmq_vhost('/mcollective') }
          end

          context 'set' do
            let(:params) { common_params.merge({ :rabbitmq_vhost => '/pies' }) }
            it { should contain_rabbitmq_vhost('/pies') }
          end
        end

        describe '#middleware_admin_user' do
          it 'should default to admin' do
            should contain_rabbitmq_user('admin').with_admin(true)
          end

          context 'bob' do
            let(:params) { common_params.merge({ :middleware_admin_user => 'bob' }) }
            it { should contain_rabbitmq_user('bob').with_admin(true) }
          end
        end

        describe '#middleware_admin_password' do
          it 'should default to secret' do
            should contain_rabbitmq_user('admin').with_password('secret')
          end

          context 'thereichangedit' do
            let(:params) { common_params.merge({ :middleware_admin_password => 'thereichangedit' }) }
            it { should contain_rabbitmq_user('admin').with_password('thereichangedit') }
          end
        end
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
