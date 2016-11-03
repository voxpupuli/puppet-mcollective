require 'spec_helper'

describe 'mcollective::actionpolicy' do
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
  context 'dummy' do
    let(:title) { 'dummy' }
    it { is_expected.to contain_datacat('mcollective::actionpolicy dummy') }
  end
end
