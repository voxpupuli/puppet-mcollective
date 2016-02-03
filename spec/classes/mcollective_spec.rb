require 'spec_helper'

def mcollective_config_path
  case Puppet.version
  when /^4.+$/
    '/etc/puppetlabs/mcollective'
  else
    '/etc/mcollective'
  end
end

def mcollective_core_libdir_path
  case Puppet.version
  when /^4.+$/
    '/opt/puppetlabs/mcollective/plugins'
  else
    '/usr/libexec/mcollective'
  end
end

def mcollective_site_libdir_path
  case Puppet.version
  when /^4.+$/
    '/opt/puppetlabs/mcollective'
  else
    '/usr/local/libexec/mcollective'
  end
end

describe 'mcollective' do
  let :facts do
    {
      :puppetversion => Puppet.version,
      :facterversion => Facter.version,
      :macaddress    => '00:00:00:26:28:8a',
    }
  end

  shared_examples_for 'a refresh-mcollective-metadata file' do |metadata_regex|
    describe 'a refresh-mcollective-metadata file' do
      it do
        should contain_file("#{mcollective_site_libdir_path}/refresh-mcollective-metadata").with_content(metadata_regex)
      end
    end
  end

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
      context 'on Debian' do
        let(:facts) do
          {
            :osfamily => 'Debian',
            :puppetversion => Puppet.version,
            :facterversion => Facter.version,
          }
        end
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
      it 'should default to the right path' do
        should contain_file('mcollective::server').with_path("#{mcollective_config_path}/server.cfg")
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
      it 'should default to true' do
        should contain_mcollective__server__setting('daemonize').with_value('1')
      end
      context 'when true' do
        let(:params) { { :server_daemonize => true } }
        it { should contain_mcollective__server__setting('daemonize').with_value('1') }
      end
      context 'when false' do
        let(:params) { { :server_daemonize => false } }
        it { should contain_mcollective__server__setting('daemonize').with_value('0') }
      end
      describe '#backwards compatibility' do
        context 'when \'1\'' do
          let(:params) { { :server_daemonize => '1' } }
          it { should contain_mcollective__server__setting('daemonize').with_value('1') }
        end
        context 'when \'0\'' do
          let(:params) { { :server_daemonize => '0' } }
          it { should contain_mcollective__server__setting('daemonize').with_value('0') }
        end
      end
      describe '#Ubuntu workaround for https://tickets.puppetlabs.com/browse/MCO-167' do
        context 'when on Ubuntu 14.04' do
          let(:facts) do
            {
              :operatingsystem => 'Ubuntu',
              :operatingsystemrelease => '14.04',
              :puppetversion => Puppet.version,
              :facterversion => Facter.version,
            }
          end
          it 'should default to false' do
            should contain_mcollective__server__setting('daemonize').with_value('0')
          end
        end
        context 'when on Ubuntu 14.10' do
          let(:facts) do
            {
              :operatingsystem => 'Ubuntu',
              :operatingsystemrelease => '14.10',
              :puppetversion => Puppet.version,
              :facterversion => Facter.version,
            }
          end
          it 'should default to false' do
            should contain_mcollective__server__setting('daemonize').with_value('0')
          end
        end
        context 'when on Ubuntu 15.04' do
          let(:facts) do
            {
              :operatingsystem => 'Ubuntu',
              :operatingsystemrelease => '15.04',
              :puppetversion => Puppet.version,
              :facterversion => Facter.version
            }
          end
          it 'should default to true' do
            should contain_mcollective__server__setting('daemonize').with_value('1')
          end
        end
      end
    end

    describe '#factsource' do
      it 'should default to yaml' do
        should contain_mcollective__server__setting('factsource').with_value('yaml')
      end

      context 'yaml_facter2' do
        let(:facts) do
          {
            :osfamily => 'RedHat',
            :number_of_cores => '42',
            :non_string => 69,
            :facterversion => '2.4.4',
            :puppetversion => Puppet.version,
          }
        end

        describe '#yaml_fact_path' do
          context 'default' do
            it 'should default to /etc/mcollective/facts.yaml' do
              should contain_mcollective__server__setting('plugin.yaml').with_value("#{mcollective_config_path}/facts.yaml")
            end
            it_should_behave_like 'a refresh-mcollective-metadata file', %r{File.rename\('#{mcollective_config_path}/facts.yaml.new', '#{mcollective_config_path}/facts.yaml'\)}
          end

          context '/tmp/facts' do
            let(:params) { { :yaml_fact_path => '/tmp/facts' } }
            it { should contain_mcollective__server__setting('plugin.yaml').with_value('/tmp/facts') }
            it_should_behave_like 'a refresh-mcollective-metadata file', %r{File.rename\('/tmp/facts.new', '/tmp/facts'\)}
          end
        end

        describe '#ruby_shebang_path' do
          [nil, false, 'false'].each do |is_pe|
            context "when is_pe == #{is_pe}" do
              let(:facts) do
                {
                  :osfamily => 'RedHat',
                  :number_of_cores => '42',
                  :non_string => 69,
                  :facterversion => '2.4.4',
                  :is_pe => is_pe,
                  :puppetversion => Puppet.version,
                }
              end
              it_should_behave_like 'a refresh-mcollective-metadata file', %r{#!/usr/bin/env ruby}
            end
          end

          [true, 'true'].each do |is_pe|
            context "when is_pe == #{is_pe}" do
              let(:facts) do
                {
                  :osfamily => 'RedHat',
                  :number_of_cores => '42',
                  :non_string => 69,
                  :facterversion => '2.4.4',
                  :is_pe => is_pe,
                  :puppetversion => Puppet.version,
                }
              end
              it_should_behave_like 'a refresh-mcollective-metadata file', %r{#!/opt/puppet/bin/ruby}
            end
          end
        end

        describe '#fact_cron_splay' do
          let(:facts) do
            {
              :puppetversion => Puppet.version,
              :facterversion => Facter.version,
              :macaddress    => '00:00:00:26:28:8a',
              # fqdn_rand gives better random numbers based on a longer fqdn
              :fqdn          => 'somereallylongfqdnthatleadstobetterrandomnumbers.example.com'
            }
          end

          context 'default (false)' do
            it { should contain_cron('refresh-mcollective-metadata').with_minute(%w(0 15 30 45)) }
          end

          context 'true' do
            let(:params) { { :fact_cron_splay => true } }
            it { should contain_cron('refresh-mcollective-metadata').with_minute(%w(8 23 38 53)) }
          end
        end

        describe '#yaml_fact_cron' do
          context 'default (true)' do
            it { should contain_cron('refresh-mcollective-metadata') }
          end

          context 'false' do
            let(:params) { { :yaml_fact_cron => false } }
            it { should_not contain_cron('refresh-mcollective-metadata') }
          end
        end
      end

      context 'yaml_facter3' do
        let(:facts) do
          {
            :osfamily => 'RedHat',
            :number_of_cores => '42',
            :non_string => 69,
            :facterversion => '3.0.1',
            :puppetversion => Puppet.version,
          }
        end

        describe '#yaml_fact_path' do
          context 'default' do
            it 'should default to /etc/mcollective/facts.yaml' do
              should contain_mcollective__server__setting('plugin.yaml').with_value("#{mcollective_config_path}/facts.yaml")
            end
            it { should_not contain_file("#{mcollective_site_libdir_path}/refresh-mcollective-metadata") }
          end

          context '/tmp/facts' do
            let(:params) { { :yaml_fact_path => '/tmp/facts' } }
            it { should contain_mcollective__server__setting('plugin.yaml').with_value('/tmp/facts') }
            it { should_not contain_file("#{mcollective_site_libdir_path}/refresh-mcollective-metadata") }
          end
        end

        describe '#yaml_fact_cron' do
          context 'default (true)' do
            it { should contain_cron('refresh-mcollective-metadata') }
          end

          context 'false' do
            let(:params) { { :yaml_fact_cron => false } }
            it { should_not contain_cron('refresh-mcollective-metadata') }
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

    describe '#factsource' do
      it 'should default to yaml' do
        should contain_mcollective__server__setting('factsource').with_value('yaml')
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
          let(:params) { { :server => true, :middleware_hosts => %w( foo bar ) } }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.size').with_value(2) }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.1.host').with_value('foo') }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.1.port').with_value('61613') }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.2.host').with_value('bar') }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.2.port').with_value('61613') }
        end

        describe '#activemq_heartbeat' do
          let(:common_params) { { :server => true } }
          let(:params) { common_params }
          context 'default' do
            it { should contain_mcollective__common__setting('plugin.activemq.heartbeat_interval').with_value('30') }
          end

          context 'set' do
            let(:params) { common_params.merge(:middleware_heartbeat_interval => '20') }
            it { should contain_mcollective__common__setting('plugin.activemq.heartbeat_interval').with_value('20') }
          end
        end

        describe '#middleware_user' do
          let(:params) { { :server => true, :middleware_hosts => %w( foo ) } }
          it 'should default to mcollective' do
            should contain_mcollective__common__setting('plugin.activemq.pool.1.user').with_value('mcollective')
          end

          context 'bob' do
            let(:params) { { :server => true, :middleware_hosts => %w( foo ), :middleware_user => 'bob' } }
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.user').with_value('bob') }
          end
        end

        describe '#middleware_password' do
          let(:params) { { :server => true, :middleware_hosts => %w( foo ) } }
          it 'should default to marionette' do
            should contain_mcollective__common__setting('plugin.activemq.pool.1.password').with_value('marionette')
          end

          context 'bob' do
            let(:params) { { :server => true, :middleware_hosts => %w( foo ), :middleware_password => 'bob' } }
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.password').with_value('bob') }
          end
        end

        describe '#middleware_ssl' do
          let(:params) { { :server => true, :middleware_hosts => %w( foo ) } }
          context 'default' do
            it { should_not contain_mcollective__common__setting('plugin.activemq.pool.1.ssl') }
            it { should_not contain_file("#{mcollective_config_path}/ssl/middleware_ca.pem") }
            it { should_not contain_file("#{mcollective_config_path}/ssl/middleware_cert.pem") }
            it { should_not contain_file("#{mcollective_config_path}/ssl/middleware_key.pem") }
          end

          context 'true' do
            let(:common_params) { { :server => true, :middleware_hosts => %w( foo ), :middleware_ssl => true } }
            let(:params) { common_params }
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.ssl').with_value('1') }
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.ssl.fallback').with_value('0') }

            describe '#middleware_ssl_ca' do
              context 'when defaulting to ssl_ca_cert (backwards compatibility)' do
                let(:params) { common_params.merge(:ssl_ca_cert => 'puppet:///modules/foo/ca_cert.pem') }
                it { should contain_file("#{mcollective_config_path}/ssl/middleware_ca.pem").with_source('puppet:///modules/foo/ca_cert.pem') }
              end
              context 'when set' do
                let(:params) { common_params.merge(:middleware_ssl_ca => '/var/lib/puppet/ssl/certs/ca.pem') }
                it { should contain_file("#{mcollective_config_path}/ssl/middleware_ca.pem").with_source('/var/lib/puppet/ssl/certs/ca.pem') }
              end
            end

            describe '#middleware_ssl_cert' do
              context 'when defaulting to ssl_server_public (backwards compatibility)' do
                let(:params) { common_params.merge(:ssl_server_public => 'puppet:///modules/foo/server_public.pem') }
                it { should contain_file("#{mcollective_config_path}/ssl/middleware_cert.pem").with_source('puppet:///modules/foo/server_public.pem') }
              end
              context 'when set' do
                let(:params) { common_params.merge(:middleware_ssl_cert => '/var/lib/puppet/ssl/certs/host.example.com.pem') }
                it { should contain_file("#{mcollective_config_path}/ssl/middleware_cert.pem").with_source('/var/lib/puppet/ssl/certs/host.example.com.pem') }
              end
            end

            describe '#middleware_ssl_key' do
              context 'when defaulting to ssl_server_private (backwards compatibility)' do
                let(:params) { common_params.merge(:ssl_server_private => 'puppet:///modules/foo/server_private.pem') }
                it { should contain_file("#{mcollective_config_path}/ssl/middleware_key.pem").with_source('puppet:///modules/foo/server_private.pem') }
              end
              context 'when set' do
                let(:params) { common_params.merge(:middleware_ssl_key => '/var/lib/puppet/ssl/private_keys/host.example.com.pem') }
                it { should contain_file("#{mcollective_config_path}/ssl/middleware_key.pem").with_source('/var/lib/puppet/ssl/private_keys/host.example.com.pem') }
              end
            end

            describe '#middleware_ssl_fallback' do
              context 'set' do
                let(:params) { common_params.merge(:middleware_ssl_fallback => true) }
                it { should contain_mcollective__common__setting('plugin.activemq.pool.1.ssl.fallback').with_value('1') }
              end
            end
          end
        end

        describe '#middleware_port' do
          let(:common_params) { { :server => true, :middleware_hosts => %w( foo ) } }
          let(:params) { common_params }
          context 'default' do
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.port').with_value('61613') }
          end

          context 'set' do
            let(:params) { common_params.merge(:middleware_port => '1701') }
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.port').with_value('1701') }
          end
        end

        describe '#middleware_ssl_port' do
          let(:common_params) { { :server => true, :middleware_hosts => %w( foo ), :middleware_ssl => true } }
          let(:params) { common_params }
          context 'default' do
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.port').with_value('61614') }
          end

          context 'set' do
            let(:params) { common_params.merge(:middleware_ssl_port => '1702') }
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
            let(:params) { common_params.merge(:rabbitmq_vhost => '/pies') }
            it { should contain_mcollective__common__setting('plugin.rabbitmq.vhost').with_value('/pies') }
          end
        end
        describe '#rabbitmq_heartbeat' do
          context 'default' do
            it { should contain_mcollective__common__setting('plugin.rabbitmq.heartbeat_interval').with_value('30') }
          end

          context 'set' do
            let(:params) { common_params.merge(:middleware_heartbeat_interval => '20') }
            it { should contain_mcollective__common__setting('plugin.rabbitmq.heartbeat_interval').with_value('20') }
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
        it { should contain_mcollective__server__setting('plugin.ssl_server_public').with_value("#{mcollective_config_path}/ssl/server_public.pem") }
        it { should contain_mcollective__server__setting('plugin.ssl_server_private').with_value("#{mcollective_config_path}/ssl/server_private.pem") }
        it { should contain_file("#{mcollective_config_path}/ssl/server_public.pem") }

        describe '#ssl_client_certs' do
          it { should contain_file("#{mcollective_config_path}/ssl/clients") }

          context 'default' do
            it { should contain_file("#{mcollective_config_path}/ssl/clients").with_source('puppet:///modules/mcollective/empty') }
          end

          context 'set' do
            let(:params) { { :server => true, :securityprovider => 'ssl', :ssl_client_certs => 'puppet:///modules/foo/clients' } }
            it { should contain_file("#{mcollective_config_path}/ssl/clients").with_source('puppet:///modules/foo/clients') }
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

      context 'allow_unconfigured' do
        let(:params) { { :server => true, :rpcauthprovider => 'action_policy', :allowunconfigured => '0' } }
        it { should contain_mcollective__server__setting('plugin.actionpolicy.allow_unconfigured').with_value('0') }
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

  describe '#core_libdir' do
    context 'default' do
      it { should contain_mcollective__common__setting('libdir').with_value("#{mcollective_site_libdir_path}") }
    end

    context 'when mco_version < 2.8' do
      let :facts do
        {
          :puppetversion => Puppet.version,
          :facterversion => Facter.version,
          :mco_version   => '2.7.0'
        }
      end
      it { should contain_mcollective__common__setting('libdir').with_value("#{mcollective_site_libdir_path}:#{mcollective_core_libdir_path}") }
    end

    context 'set' do
      let(:params) { { :core_libdir => '/usr/libexec/fishy/fishy' } }
      it { should contain_mcollective__common__setting('libdir').with_value("#{mcollective_site_libdir_path}:/usr/libexec/fishy/fishy") }
    end
  end

  describe '#site_libdir' do
    context 'default' do
      it { should contain_file(mcollective_site_libdir_path).with_mode('0644') }
      it { should contain_mcollective__common__setting('libdir').with_value("#{mcollective_site_libdir_path}") }
    end

    context 'when mco_version < 2.8' do
      let :facts do
        {
          :puppetversion => Puppet.version,
          :facterversion => Facter.version,
          :mco_version   => '2.7.0'
        }
      end
      it { should contain_mcollective__common__setting('libdir').with_value("#{mcollective_site_libdir_path}:#{mcollective_core_libdir_path}") }
    end

    context 'set' do
      let(:params) { { :site_libdir => '/usr/local/fishy/fishy' } }
      it { should contain_file('/usr/local/fishy/fishy') }
      it { should contain_mcollective__common__setting('libdir').with_value('/usr/local/fishy/fishy') }
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
      it 'should default to the right path' do
        should contain_file('mcollective::client').with_path("#{mcollective_config_path}/client.cfg")
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
          let(:params) { { :server => false, :client => true, :middleware_hosts => %w( foo bar ) } }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.size').with_value(2) }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.1.host').with_value('foo') }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.1.port').with_value('61613') }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.2.host').with_value('bar') }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.2.port').with_value('61613') }
        end

        describe '#middleware_user' do
          let(:params) { { :server => false, :client => true, :middleware_hosts => %w( foo ) } }
          it 'should default to mcollective' do
            should contain_mcollective__common__setting('plugin.activemq.pool.1.user').with_value('mcollective')
          end

          context 'bob' do
            let(:params) { { :server => false, :client => true, :middleware_hosts => %w( foo ), :middleware_user => 'bob' } }
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.user').with_value('bob') }
          end
        end

        describe '#middleware_password' do
          let(:params) { { :server => false, :client => true, :middleware_hosts => %w( foo ) } }
          it 'should default to marionette' do
            should contain_mcollective__common__setting('plugin.activemq.pool.1.password').with_value('marionette')
          end

          context 'bob' do
            let(:params) { { :server => false, :client => true, :middleware_hosts => %w( foo ), :middleware_password => 'bob' } }
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.password').with_value('bob') }
          end
        end

        describe '#middleware_ssl' do
          let(:params) { { :server => false, :client => true, :middleware_hosts => %w( foo ) } }
          it 'should default to false' do
            should_not contain_mcollective__common__setting('plugin.activemq.pool.1.ssl')
          end

          context 'true' do
            let(:params) { { :server => false, :client => true, :middleware_hosts => %w( foo ), :middleware_ssl => true } }
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.ssl').with_value('1') }
            it { should contain_mcollective__common__setting('plugin.activemq.pool.1.ssl.fallback').with_value('0') }

            describe '#ssl_server_fallback' do
              context 'set' do
                let(:params) { { :server => false, :client => true, :middleware_hosts => %w( foo ), :middleware_ssl => true, :middleware_ssl_fallback => true } }
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
        it { should contain_mcollective__server__setting('plugin.ssl_server_public').with_value("#{mcollective_config_path}/ssl/server_public.pem") }
        it { should contain_file("#{mcollective_config_path}/ssl/server_public.pem") }
      end

      context 'psk' do
        let(:params) { { :server => true, :securityprovider => 'psk' } }
        it { should contain_mcollective__common__setting('securityprovider').with_value('psk') }
        it { should contain_mcollective__common__setting('plugin.psk').with_value('changemeplease') }
      end
    end
  end
end
