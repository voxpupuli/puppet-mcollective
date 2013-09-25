require 'spec_helper'

describe 'mcollective::user' do
  let(:title) { 'nagios' }
  let(:default_params) { { :connector => 'activemq', :middleware_hosts => ['localhost'] } }
  let(:params) { default_params }
  it { should contain_file('/home/nagios/.mcollective.d') }
  it { should contain_file('mcollective::user nagios').with_path('/home/nagios/.mcollective') }

  describe '#securityprovider' do
    context 'ssl' do
      let(:params) { default_params.merge({ :securityprovider => 'ssl' }) }
      it { should contain_file('/home/nagios/.mcollective.d/credentials/certs/nagios.pem') }
      it { should contain_file('/home/nagios/.mcollective.d/credentials/private_keys/nagios.pem') }
      it { should contain_mcollective__user__setting('nagios:plugin.ssl_client_public') }
      it { should contain_mcollective__user__setting('nagios:plugin.ssl_client_public').with_value('/home/nagios/.mcollective.d/credentials/certs/nagios.pem') }
      it { should contain_mcollective__user__setting('nagios:plugin.ssl_client_private') }
      it { should contain_mcollective__user__setting('nagios:plugin.ssl_server_public') }
    end

    context 'pies' do
      let(:params) { default_params.merge({ :securityprovider => 'pies' }) }
      it { should_not contain_file('/home/nagios/.mcollective.d/credentials/certs/nagios.pem') }
      it { should_not contain_mcollective__user__setting('nagios:plugin.ssl_client_public') }
      it { should_not contain_mcollective__user__setting('nagios:plugin.ssl_client_private') }
      it { should_not contain_mcollective__user__setting('nagios:plugin.ssl_server_public') }
    end
  end

  describe '#middleware_ssl' do
    context 'true' do
      let(:params) { default_params.merge({ :middleware_ssl => true }) }
      it { should contain_file('/home/nagios/.mcollective.d/credentials/private_keys/nagios.pem') }
      it { should contain_mcollective__user__setting('nagios plugin.activemq.pool.1.ssl.cert') }
      it { should contain_mcollective__user__setting('nagios plugin.activemq.pool.1.ssl.cert').with_value('/home/nagios/.mcollective.d/credentials/certs/nagios.pem') }
    end

    context 'false' do
      let(:params) { default_params.merge({ :middleware_ssl => false }) }
      it { should_not contain_mcollective__user__setting('nagios plugin.activemq.pool.1.ssl.cert') }
    end
  end
end
