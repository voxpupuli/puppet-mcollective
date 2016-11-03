require 'spec_helper'

describe 'mcollective::user::setting' do
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
  context 'nagios:some_setting' do
    let(:title) { 'nagios:some_setting' }
    let(:params) { { 'username' => 'nagios', 'value' => 'pie', :setting => 'some_setting' } }
    it { is_expected.to contain_mcollective__setting('mcollective::user::setting nagios:some_setting') }
    it { is_expected.to contain_mcollective__setting('mcollective::user::setting nagios:some_setting').with_setting('some_setting') }
    it { is_expected.to contain_mcollective__setting('mcollective::user::setting nagios:some_setting').with_value('pie') }
    it { is_expected.to contain_mcollective__setting('mcollective::user::setting nagios:some_setting').with_target('mcollective::user nagios') }
  end
end
