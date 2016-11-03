require 'spec_helper'

describe 'mcollective::client::setting' do
  let :facts do
    {
      puppetversion: Puppet.version,
      facterversion: Facter.version,
      macaddress: '00:00:00:26:28:8a',
      osfamily: 'RedHat',
      operatingsystem: 'CentOS',
      mco_version: '2.8.4',
      path: ['/usr/bin', '/usr/sbin']
    }
  end
  context 'some_setting' do
    let(:title) { 'some_setting' }
    let(:params) { { 'value' => 'pie' } }
    it { is_expected.to contain_mcollective__setting('mcollective::client::setting some_setting') }
    it { is_expected.to contain_mcollective__setting('mcollective::client::setting some_setting').with_setting('some_setting') }
    it { is_expected.to contain_mcollective__setting('mcollective::client::setting some_setting').with_value('pie') }
    it { is_expected.to contain_mcollective__setting('mcollective::client::setting some_setting').with_target(%w(mcollective::client mcollective::user)) }
  end
end
